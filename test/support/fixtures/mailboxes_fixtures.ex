defmodule Resolvd.MailboxesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resolvd.Accounts` context.
  """

  def unique_mailbox_name, do: "Mailbox ##{System.unique_integer()}"
  def unique_mailbox_email, do: "user#{System.unique_integer()}@example.com"
  def valid_mailbox_from, do: "John Doe"
  def valid_mailbox_server, do: "localhost"
  def valid_mailbox_password, do: "mail_password"

  def valid_server_attrs(attrs \\ %{}) do
    Enum.into(attrs, %{
      server: valid_mailbox_server(),
      username: unique_mailbox_email(),
      password: valid_mailbox_password()
    })
  end

  def valid_mailbox_attrs(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: unique_mailbox_name(),
      from: valid_mailbox_from(),
      email_address: unique_mailbox_email(),
      inbound_config: valid_server_attrs(),
      outbound_config: valid_server_attrs()
    })
  end

  def mailbox_fixture(%Resolvd.Accounts.User{} = user, attrs \\ %{}) do
    params = valid_mailbox_attrs(attrs)

    {:ok, mailbox} = Resolvd.Mailboxes.create_mailbox(user, params)
    mailbox
  end

  def mailbox_fixture() do
    user = Resolvd.AccountsFixtures.user_fixture()
    params = valid_mailbox_attrs()

    {:ok, mailbox} = Resolvd.Mailboxes.create_mailbox(user, params)
    mailbox
  end
end
