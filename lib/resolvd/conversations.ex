defmodule Resolvd.Conversations do
  @moduledoc """
  The Conversations context.
  """

  import Ecto.Query, warn: false
  alias Resolvd.Repo

  alias Resolvd.Accounts.User
  alias Resolvd.Conversations.Conversation

  @doc """
  Returns the list of conversations.

  ## Examples

      iex> list_conversations()
      [%Conversation{}, ...]

  """
  def list_conversations do
    Repo.all(from(c in Conversation, order_by: [desc: c.inserted_at]))
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

  @doc """
  Creates a conversation.

  ## Examples

      iex> create_conversation(%{field: value})
      {:ok, %Conversation{}}

      iex> create_conversation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_conversation(subject, body) do
    %Conversation{}
    |> Conversation.changeset(%{
      subject: subject
    })
    |> Ecto.build_assoc(:messages, %{
      text_body: body,
      html_body: body
    })
    |> Repo.insert()
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
    in_reply_to = get_probable_in_reply_to_for_conversation(conversation) |> dbg()

    creation =
      %Message{
        conversation: conversation,
        user: user,
        email_message_id: message_id
      }
      |> Message.changeset(attrs)
      |> Repo.insert()

    case creation do
      {:ok, message} ->
        email =
          Swoosh.Email.new(headers: %{"Message-ID" => message_id, "In-Reply-To" => in_reply_to})
          |> Swoosh.Email.to(conversation.customer.email)
          |> Swoosh.Email.from({"Resolvd", "aida@axxim.net"})
          |> Swoosh.Email.subject(conversation.subject)
          |> Swoosh.Email.html_body(message.html_body)

        with {:ok, _metadata} <- Resolvd.Mailer.deliver(email) do
          {:ok, email}
        end

      _ ->
        nil
    end

    creation
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
        %Resolvd.Tenants.Tenant{} = tenant,
        %Resolvd.Mailbox.Mail{} = email
      ) do
    if not is_nil(get_message_by_email_message_id(email.message_id)) do
      # If we've already seen this message ID -- ignore it!
      {:ok, :dupe}
    else
      # New message, do we have a conversation for any of it's references or reply tos?
      customer = Resolvd.Customers.get_or_create_customer_from_email(tenant, email.sender)

      conversation =
        if existing_message = get_message_by_email_message_id(email.in_reply_to) do
          # Existing conversation
          existing_message.conversation
        else
          # New conversation
          {:ok, conversation} =
            %Conversation{tenant: tenant, customer: customer}
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
