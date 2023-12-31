defmodule Resolvd.ConversationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resolvd.Accounts` context.
  """

  alias Resolvd.Accounts.User
  alias Resolvd.Mailboxes.Mail
  alias Resolvd.Mailboxes.Mailbox
  alias Resolvd.Conversations
  alias Resolvd.Customers.Customer

  def unique_conversation_subject, do: "Conversation ##{System.unique_integer()}"
  def unique_message_email, do: "user##{System.unique_integer()}@localhost"
  def unique_user_name, do: "user##{System.unique_integer()}"

  def valid_text_body, do: "Hello World #{System.unique_integer()}"
  def valid_html_body, do: "<h1>Hello World #{System.unique_integer()}</h1>"
  def valid_message_id, do: :smtp_util.generate_message_id() |> to_string()

  def valid_message_attrs(attrs \\ %{}) do
    Enum.into(attrs, %{
      text_body: valid_text_body(),
      html_body: valid_html_body(),
      email_message_id: valid_message_id()
    })
  end

  def valid_conversation_attrs(attrs \\ %{}) do
    Enum.into(attrs, %{
      subject: unique_conversation_subject()
    })
  end

  def valid_mail_attrs(attrs \\ %{}) do
    Enum.into(attrs, %{
      sender: unique_message_email(),
      subject: unique_conversation_subject(),
      from: [{unique_user_name(), unique_message_email()}],
      message_id: valid_message_id(),
      text_body: valid_text_body(),
      html_body: valid_html_body()
    })
  end

  def mail_fixture(attrs \\ %{}) do
    struct(Mail, valid_mail_attrs(attrs))
  end

  def conversation_fixture_mail(attrs \\ %{})

  def conversation_fixture_mail(%User{} = user) do
    email = mail_fixture()
    mailbox = Resolvd.MailboxesFixtures.mailbox_fixture(user)

    {:ok, conversation} = Conversations.create_or_update_conversation_from_email(mailbox, email)

    conversation
  end

  def conversation_fixture_mail(%Mailbox{} = mailbox) do
    email = mail_fixture()

    {:ok, conversation} = Conversations.create_or_update_conversation_from_email(mailbox, email)

    conversation
  end

  def conversation_fixture_mail(attrs) do
    email = mail_fixture(attrs)
    mailbox = Resolvd.MailboxesFixtures.mailbox_fixture()

    {:ok, conversation} = Conversations.create_or_update_conversation_from_email(mailbox, email)

    conversation
  end

  def conversation_fixture_user(%User{} = user) do
    make_conversation_user(user)
  end

  def conversation_fixture_user() do
    user = Resolvd.AccountsFixtures.user_fixture()
    make_conversation_user(user)
  end

  def conversation_fixture(%User{} = user, %Customer{} = customer, %Mailbox{} = _mailbox) do
    {:ok, conversation} =
      Conversations.create_conversation(
        user,
        customer.email,
        unique_conversation_subject(),
        valid_text_body()
      )

    conversation
  end

  defp make_conversation_user(%User{} = user) do
    _mailbox = Resolvd.MailboxesFixtures.mailbox_fixture(user)

    {:ok, conversation} =
      Conversations.create_conversation(
        user,
        unique_message_email(),
        unique_conversation_subject(),
        valid_text_body()
      )

    conversation
  end
end
