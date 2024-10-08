defmodule Resolvd.Conversations do
  @moduledoc """
  The Conversations context.
  """

  import Ecto.Query, warn: false
  alias Resolvd.Repo

  alias Resolvd.Tenants
  alias Resolvd.Accounts.User
  alias Resolvd.Conversations.Conversation
  alias Resolvd.Conversations.Message
  alias Resolvd.Mailboxes.Mailbox
  alias Resolvd.Mailboxes

  @filters [:all, :me, :unassigned, :prioritized, :resolved]

  @doc """
  Returns the list of conversations.

  ## Examples

      iex> list_conversations(user)
      [%Conversation{}, ...]

  """
  def list_conversations(%User{} = user) do
    from(c in Conversation,
      order_by: [desc: c.inserted_at],
      limit: 100,
      preload: [:customer, :user]
    )
    |> Bodyguard.scope(user)
    |> Repo.all()
    |> Repo.preload(:mailbox)
  end

  def list_conversations_by_mailbox(%User{} = user, nil) do
    list_conversations(user)
  end

  def list_conversations_by_mailbox(%User{} = user, mailbox_id) do
    from(c in Conversation,
      where: c.mailbox_id == ^mailbox_id,
      order_by: [desc: c.inserted_at],
      preload: [:customer, :user]
    )
    |> Bodyguard.scope(user)
    |> Repo.all()
    |> Repo.preload(:mailbox)
  end

  @doc """
  Returns the list of conversation filtered by `action`.

  ## Examples

      iex> filter_conversations(user, :all)
      [%Conversation{}, ...]
  """

  def filter_conversations(%User{} = user, action) when action in @filters do
    Conversation
    |> filter_by_action(action, user)
    |> order_by([c], desc: c.updated_at)
    |> preload([:customer, :user, :mailbox])
    |> Bodyguard.scope(user)
    |> Repo.all()
  end

  @doc """
  Searches the given string in the conversation.
  """
  def search_conversation(%User{} = user, search_query, action) when action in @filters do
    search_query = "%#{Resolvd.Helpers.sanitize_sql_like(search_query)}%"

    query =
      from c in Conversation,
        join: m in Message,
        on: c.id == m.conversation_id,
        where: ilike(m.text_body, ^search_query),
        or_where: ilike(m.html_body, ^search_query),
        or_where: ilike(c.subject, ^search_query),
        order_by: [desc: c.updated_at],
        select: c,
        distinct: c,
        preload: [:customer, :user, :mailbox]

    query
    |> filter_by_action(action, user)
    |> Repo.all()
  end

  @doc """
  Gets a single conversation.

  Raises `Ecto.NoResultsError` if the Conversation does not exist.

  ## Examples

      iex> get_conversation!(123)
      %Conversation{}

      iex> get_conversation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_conversation!(id),
    do:
      Repo.get!(Conversation, id)
      |> Repo.preload([:messages, :customer, messages: [:customer, :user]])

  def get_conversation(id),
    do:
      Repo.get(Conversation, id)
      |> Repo.preload([:messages, :customer, messages: [:customer, :user]])

  def get_conversation!(%User{} = user, id) do
    Conversation
    |> Bodyguard.scope(user)
    |> where(id: ^id)
    |> Repo.one!()
    |> Repo.preload([:customer, :user, :mailbox])
  end

  @doc """
  Creates a conversation.

  ## Examples

      iex> create_conversation(%{field: value})
      {:ok, %Conversation{}}

      iex> create_conversation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_conversation(
        %User{} = user,
        customer_email,
        subject,
        body,
        notify_customer \\ false
      ) do
    tenant = Resolvd.Tenants.get_tenant_for_user!(user)
    customer = Resolvd.Customers.get_or_create_customer_from_email(tenant, customer_email)
    message_id = to_string(:smtp_util.generate_message_id())

    # FIXME: Accept mailbox from the user creating the conversation
    mailbox = Resolvd.Mailboxes.get_any_mailbox!(user)

    {:ok, conversation} =
      %Conversation{tenant: tenant, customer: customer}
      |> Conversation.changeset(%{
        subject: subject
      })
      |> Ecto.Changeset.put_assoc(:mailbox, mailbox)
      |> Repo.insert()

    %Message{
      conversation: conversation,
      customer: customer
    }
    |> Message.changeset(%{
      text_body: body,
      html_body: body,
      email_message_id: message_id
    })
    |> Repo.insert()

    if notify_customer do
      %{
        conversation_id: conversation.id,
        mailbox_id: conversation.mailbox_id,
        headers: %{"Message-ID" => message_id},
        customer_email: customer.email,
        subject: subject,
        html_body: body,
        text_body: body
      }
      |> Resolvd.Workers.SendCustomerEmail.new()
      |> Oban.insert()
    end

    {:ok, get_conversation!(conversation.id)}
  end

  @doc """
  Updates a conversation's associated mailbox
  """
  def update_conversation_mailbox(%Conversation{} = conversation, %Mailbox{} = mailbox) do
    conversation
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:mailbox_id, mailbox.id)
    |> Repo.update!()
  end

  @doc """
  Updates a conversation's associated user
  """
  def update_conversation_user(%Conversation{} = conversation, %User{} = user) do
    conversation
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:user_id, user.id)
    |> Repo.update!()
  end

  def update_conversation_user(%Conversation{} = conversation, nil) do
    conversation
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:user_id, nil)
    |> Repo.update!()
  end

  def set_priority(%Conversation{} = conversation, prioritized \\ false) do
    {:ok, conversation} = update_conversation(conversation, %{is_prioritized: prioritized})

    conversation
  end

  def set_resolved(%Conversation{} = conversation, resolved \\ false) do
    {:ok, conversation} = update_conversation(conversation, %{is_resolved: resolved})

    conversation
  end

  @doc """
  Updates a conversation.

  ## Examples

      iex> update_conversation(conversation, %{field: new_value})
      {:ok, %Conversation{}}

      iex> update_conversation(conversation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_conversation(%Conversation{} = conversation, attrs) do
    conversation
    |> Conversation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a conversation.

  ## Examples

      iex> delete_conversation(conversation)
      {:ok, %Conversation{}}

      iex> delete_conversation(conversation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_conversation(%Conversation{} = conversation) do
    Repo.delete(conversation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking conversation changes.

  ## Examples

      iex> change_conversation(conversation)
      %Ecto.Changeset{data: %Conversation{}}

  """
  def change_conversation(%Conversation{} = conversation, attrs \\ %{}) do
    Conversation.changeset(conversation, attrs)
  end

  alias Resolvd.Conversations.Message

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages_for_conversation(%Conversation{id: id}) do
    Repo.all(from(m in Message, where: m.conversation_id == ^id, order_by: m.inserted_at))
    |> Repo.preload([:customer, :user])
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  def get_message_by_email_message_id(nil),
    do: nil

  def get_message_by_email_message_id(message_id),
    do: Repo.get_by(Message, email_message_id: message_id) |> Repo.preload(:conversation)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(%Conversation{} = conversation, %User{} = user, attrs \\ %{}) do
    # Email message ID
    message_id = to_string(:smtp_util.generate_message_id())
    in_reply_to = get_probable_in_reply_to_for_conversation(conversation)

    creation =
      %Message{
        conversation: conversation,
        user: user,
        email_message_id: message_id
      }
      |> Message.changeset(attrs)
      |> Repo.insert()

    # conversation =
    #   with %Conversation{user_id: nil, id: conversation_id} <- conversation,
    #        %Conversation{user_id: nil} = conversation <- get_conversation!(user, conversation_id) do
    #     conversation
    #     |> Ecto.Changeset.change()
    #     |> Ecto.Changeset.put_assoc(:user, user)
    #     |> Repo.update!()
    #   end

    case creation do
      {:ok, message} ->
        Phoenix.PubSub.broadcast(
          Resolvd.PubSub,
          conversation.id,
          {ResolvdWeb.ConversationLive.MessageComponent, {:saved, message, conversation}}
        )

        %{
          conversation_id: conversation.id,
          mailbox_id: conversation.mailbox_id,
          headers: %{"Message-ID" => message_id, "In-Reply-To" => in_reply_to},
          customer_email: conversation.customer.email,
          subject: conversation.subject,
          html_body: message.html_body,
          text_body: HtmlSanitizeEx.strip_tags(message.html_body)
        }
        |> Resolvd.Workers.SendCustomerEmail.new()
        |> Oban.insert()

      _ ->
        nil
    end

    {creation, conversation}
  end

  def get_probable_in_reply_to_for_conversation(%Conversation{} = conversation) do
    Repo.one(
      from(m in Message,
        select: m.email_message_id,
        where: m.conversation_id == ^conversation.id,
        order_by: [desc: m.inserted_at],
        limit: 1
      )
    )
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  def create_or_update_conversation_from_email(
        %Resolvd.Mailboxes.Mailbox{} = mailbox,
        %Resolvd.Mailboxes.Mail{} = email
      ) do
    if not is_nil(get_message_by_email_message_id(email.message_id)) do
      # If we've already seen this message ID -- ignore it!
      {:ok, :dupe}
    else
      # New message, do we have a conversation for any of it's references or reply tos?
      tenant = Tenants.get_tenant!(mailbox.tenant_id)

      name = email.from |> hd |> elem(0) |> Mailboxes.parse_mime_encoded_word()
      customer = Resolvd.Customers.get_or_create_customer_from_email(tenant, email.sender, name)

      conversation =
        if existing_message = get_message_by_email_message_id(email.in_reply_to) do
          # Existing conversation
          existing_message.conversation
        else
          # New conversation
          {:ok, conversation} =
            %Conversation{tenant: tenant, mailbox: mailbox, customer: customer}
            |> Conversation.changeset(%{
              subject: email.subject |> Mailboxes.parse_mime_encoded_word()
            })
            |> Repo.insert()

          conversation
        end

      {:ok, message} =
        %Message{
          conversation: conversation,
          customer: customer
        }
        |> Message.changeset(%{
          email_message_id: email.message_id,
          text_body: email.text_body,
          html_body: email.html_body
        })
        |> Repo.insert()

      message =
        get_message!(message.id)
        |> Repo.preload([:customer, :user])

      conversation = get_conversation!(conversation.id)
      dbg("Got here")

      Phoenix.PubSub.broadcast(
        Resolvd.PubSub,
        conversation.id,
        {ResolvdWeb.ConversationLive.MessageComponent, {:saved, message, conversation}}
      )

      {:ok, conversation}
    end
  end

  defp filter_by_action(query, action, user) do
    case action do
      :all -> query |> where(is_resolved: false)
      :me -> query |> where(is_resolved: false, user_id: ^user.id)
      :unassigned -> query |> where(is_resolved: false) |> where([c], is_nil(c.user_id))
      :prioritized -> query |> where(is_resolved: false, is_prioritized: true)
      :resolved -> query |> where(is_resolved: true)
    end
  end
end
