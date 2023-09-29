defmodule Resolvd.MailboxesTest do
  alias Resolvd.Mailboxes
  use Resolvd.DataCase

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
end
