defmodule Resolvd.TenantsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resolvd.Tenants` context.
  """

  @doc """
  Generate a conversation.
  """
  def mailbox_fixture(attrs \\ %{}) do
    {:ok, mailbox} =
      attrs
      |> Enum.into(%{
        name: "some name",
        from: "some from",
        email_address: "some@example.com"
      })
      |> Resolvd.Mailboxes.create_mailbox()

    mailbox
  end
end
