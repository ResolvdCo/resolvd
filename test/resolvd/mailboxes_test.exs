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

  describe "Parse mime encoded word" do
    test "non encoded strings" do
      assert Mailboxes.parse_mime_encoded_word("") == ""
      assert Mailboxes.parse_mime_encoded_word("Hello") == "Hello"
      assert Mailboxes.parse_mime_encoded_word("Hello World!") == "Hello World!"
    end

    test "ISO-8859-1 encoded strings" do
      assert Mailboxes.parse_mime_encoded_word("=?iso-8859-1?Q?R=E9sum=E9?=") == "Résumé"
      assert Mailboxes.parse_mime_encoded_word("=?iso-8859-1?B?UulzdW3p?=") == "Résumé"
    end

    test "UTF-8 encoded strings" do
      assert Mailboxes.parse_mime_encoded_word("=?utf-8?Q?Caf=C3=A9?=") == "Café"
      assert Mailboxes.parse_mime_encoded_word("=?utf-8?B?Q2Fmw6k=?=") == "Café"

      assert Mailboxes.parse_mime_encoded_word("=?utf-8?B?8J+YjPCfmIw=?=") == "😌😌"
      assert Mailboxes.parse_mime_encoded_word("=?utf-8?Q?=F0=9F=98=8C=F0=9F=98=8C?=") == "😌😌"
    end
  end
end
