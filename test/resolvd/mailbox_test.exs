defmodule Resolvd.MailboxTest do
  alias Resolvd.Mailbox
  use Resolvd.DataCase

  alias Resolvd.Tenants
  alias Resolvd.Tenants.TenantCreation

  describe "Mailbox Helpers" do
    test "get_body/2 works properly" do
      assert Mailbox.Mail.get_body(
               {"text/plain", %{"CHARSET" => "ascii"}, "Hello world!\r\n"},
               "text/plain"
             ) == "Hello world!\r\n"

      assert Mailbox.Mail.get_body(
               {"text/plain", %{"CHARSET" => "ascii"}, "Hello world!\r\n"},
               "text/html"
             ) == "Hello world!\r\n"

      assert Mailbox.Mail.get_body(
               [],
               "text/html"
             ) == ""
    end
  end
end
