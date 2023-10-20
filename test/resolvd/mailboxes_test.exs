defmodule Resolvd.MailboxesTest do
  alias Resolvd.Mailboxes
  use Resolvd.DataCase

  import Resolvd.MailboxesFixtures
  import Resolvd.AccountsFixtures

  describe "Mailbox Helpers" do
    test "get_body/2 works properly" do
      assert Mailboxes.Mail.get_body(
               {"text/plain", %{"CHARSET" => "ascii"}, "Hello world!\r\n"},
               "text/plain"
             ) == "Hello world!\r\n"

      assert Mailboxes.Mail.get_body(
               {"text/plain", %{"CHARSET" => "ascii"}, "Hello world!\r\n"},
               "text/html"
             ) == "Hello world!\r\n"

      assert Mailboxes.Mail.get_body(
               [],
               "text/html"
             ) == ""
    end
  end

  describe "Mailbox creation" do
    setup do
      user = user_fixture()
      %{user: user, mailbox: mailbox_fixture(user)}
    end

    test "create new mailbox", %{mailbox: mailbox} do
      assert mailbox.id
    end
  end
end
