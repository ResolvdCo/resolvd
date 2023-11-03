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

  @doc """
  Returns the list of conversations.

  ## Examples

      iex> list_conversations(user)
      [%Conversation{}, ...]

  """
  def list_conversations(%User{} = user) do
    from(c in Conversation, order_by: [desc: c.inserted_at])
    |> Bodyguard.scope(user)
    |> Repo.all()
  end

  @doc """
  Returns the list of unresolved conversations.

  ## Examples

      iex> list_unresolved_conversations(user)
      [%Conversation{}, ...]

  """
  def list_unresolved_conversations(%User{} = user) do
    from(c in Conversation,
      where: [is_resolved: false],
      order_by: [desc: c.inserted_at],
      preload: [:customer]
    )
    |> Bodyguard.scope(user)
    |> Repo.all()
  end

  @doc """
  Returns the list of unresolved conversations assigned to the user.

  ## Examples

      iex> list_conversations_assigned_to_me(user)
      [%Conversation{}, ...]

  """
  def list_conversations_assigned_to_me(%User{} = user) do
    from(c in Conversation,
      where: [is_resolved: false, user_id: ^user.id],
      order_by: [desc: c.inserted_at],
      preload: [:customer]
    )
    |> Bodyguard.scope(user)
    |> Repo.all()
  end

  @doc """
  Returns the list of unassigned conversations.

  ## Examples

      iex> list_unassigned_conversations(user)
      [%Conversation{}, ...]

  """
  def list_unassigned_conversations(%User{} = user) do
    from(c in Conversation,
      where: [is_resolved: false],
      where: is_nil(c.user_id),
      order_by: [desc: c.inserted_at],
      preload: [:customer]
    )
    |> Bodyguard.scope(user)
    |> Repo.all()
  end

  @doc """
  Returns the list of prioritized conversations.

  ## Examples

      iex> list_prioritized_conversations(user)
      [%Conversation{}, ...]

  """
  def list_prioritized_conversations(%User{} = user) do
    from(c in Conversation,
      where: [is_resolved: false, is_prioritized: true],
      order_by: [desc: c.inserted_at],
      preload: [:customer]
    )
    |> Bodyguard.scope(user)
    |> Repo.all()
  end

  @doc """
  Returns the list of resolved conversations.

  ## Examples

      iex> list_resolved_conversations(user)
      [%Conversation{}, ...]

  """
  def list_resolved_conversations(%User{} = user) do
    from(c in Conversation,
      where: [is_resolved: true],
      order_by: [desc: c.inserted_at],
      preload: [:customer]
    )
    |> Bodyguard.scope(user)
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
    |> Repo.preload([:customer, :user])
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
    Repo.all(from(m in Message, where: m.conversation_id == ^id))
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

    conversation =
      with %Conversation{user_id: nil, id: conversation_id} <- conversation,
           %Conversation{user_id: nil} = conversation <- get_conversation!(user, conversation_id) do
        conversation
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:user, user)
        |> Repo.update!()
      end

    case creation do
      {:ok, message} ->
        %{
          mailbox_id: conversation.mailbox_id,
          headers: %{"Message-ID" => message_id, "In-Reply-To" => in_reply_to},
          customer_email: conversation.customer.email,
          subject: conversation.subject,
          html_body: message.html_body,
          text_body: message.text_body
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

      name = email.from |> hd |> elem(0)
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
              subject: email.subject
            })
            |> Repo.insert()

          conversation
        end

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

      {:ok, get_conversation!(conversation.id)}
    end
  end
end
