defmodule Resolvd.MailboxesTest do
  use Resolvd.DataCase

  import Resolvd.MailboxesFixtures
  import Resolvd.AccountsFixtures

  alias Resolvd.Mailboxes
  alias Resolvd.Mailboxes.Mail

  describe "Mailbox Helpers" do
    test "get_body/2 works properly" do
      assert Mailboxes.Mail.get_body(
               {"text/plain", %{"CHARSET" => "ascii"}, "Hello world!\r\n"},
               "text/plain"
             ) == "Hello world!\r\n"

      assert Mailboxes.Mail.get_body(
               {"text/html", %{"CHARSET" => "ascii"}, "<h1>Hello world!</h1>"},
               "text/html"
             ) == "<h1>Hello world!</h1>"

      assert Mailboxes.Mail.get_body(
               {"text/plain", %{"CHARSET" => "ascii"}, "Hello world!\r\n"},
               "text/html"
             ) == nil

      assert Mailboxes.Mail.get_body(
               {"text/html", %{"CHARSET" => "ascii"}, "<h1>Hello world!</h1>"},
               "text/plain"
             ) == nil

      assert Mailboxes.Mail.get_body(
               [],
               "text/html"
             ) == nil
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

  describe "Parse mail from yugo  type" do
    test "mail with only text/plain onepart" do
      yugo_msg = %{
        bcc: [],
        body: {"text/plain", %{"charset" => "utf-8", "format" => "flowed"}, "Hello 123\r\n456"},
        cc: [],
        date: ~U[2022-12-07 13:02:41Z],
        flags: [:seen],
        in_reply_to: nil,
        message_id: "fjaelwkjfi oaf<$ ))) \"",
        reply_to: [{"Marge", "marge@simpsons-family.com"}],
        sender: [{"Marge Simpson", "marge@simpsons-family.com"}],
        subject: nil,
        to: [{"HOMIEEEE", "homer@simpsons-family.com"}],
        from: [{"Marge Simpson", "marge@simpsons-family.com"}]
      }

      assert Mail.from_yugo_type(yugo_msg) == %Mail{
               bcc: [],
               text_body: "Hello 123\r\n456",
               html_body: nil,
               cc: [],
               date: ~U[2022-12-07 13:02:41Z],
               flags: [:seen],
               in_reply_to: nil,
               message_id: "fjaelwkjfi oaf<$ ))) \"",
               reply_to: [{"Marge", "marge@simpsons-family.com"}],
               sender: "marge@simpsons-family.com",
               subject: nil,
               to: [{"HOMIEEEE", "homer@simpsons-family.com"}],
               from: [{"Marge Simpson", "marge@simpsons-family.com"}]
             }
    end

    test "mail with only text/html onepart" do
      yugo_msg = %{
        bcc: [],
        body:
          {"text/html", %{"charset" => "us-ascii"},
           "<div id=\"geary-body\" dir=\"auto\"><u><font size=\"1\">Wow!!</font></u><div><br></div><div>This <b>email</b>&nbsp;has <font face=\"monospace\" color=\"#f5c211\">rich text</font><font face=\"sans\">!</font></div></div>"},
        cc: [],
        date: ~U[2022-12-08 04:59:48Z],
        flags: [],
        in_reply_to: nil,
        message_id: "<><><><><>",
        reply_to: [{nil, "foo@bar.com"}],
        sender: [{nil, "person@domain.com"}],
        subject: "An HTML email",
        to: [{nil, "bar@foo.com"}],
        from: [{"Aych T. Emmel", "person@domain.com"}]
      }

      assert Mail.from_yugo_type(yugo_msg) == %Mail{
               bcc: [],
               text_body: nil,
               html_body:
                 "<div id=\"geary-body\" dir=\"auto\"><u><font size=\"1\">Wow!!</font></u><div><br></div><div>This <b>email</b>&nbsp;has <font face=\"monospace\" color=\"#f5c211\">rich text</font><font face=\"sans\">!</font></div></div>",
               cc: [],
               date: ~U[2022-12-08 04:59:48Z],
               flags: [],
               in_reply_to: nil,
               message_id: "<><><><><>",
               reply_to: [{nil, "foo@bar.com"}],
               sender: "person@domain.com",
               subject: "An HTML email",
               to: [{nil, "bar@foo.com"}],
               from: [{"Aych T. Emmel", "person@domain.com"}]
             }
    end

    test "mail with both html and text onpart bodies" do
      yugo_msg = %{
        bcc: [],
        body: [
          {"text/plain", %{"charset" => "us-ascii"},
           "_Wow!!_\r\n\r\nThis *email* has rich text!\r\n\r\n"},
          {"text/html", %{"charset" => "us-ascii"},
           "<div id=\"geary-body\" dir=\"auto\"><u><font size=\"1\">Wow!!</font></u><div><br></div><div>This <b>email</b>&nbsp;has <font face=\"monospace\" color=\"#f5c211\">rich text</font><font face=\"sans\">!</font></div></div>"}
        ],
        cc: [],
        date: ~U[2022-12-08 04:59:48Z],
        flags: [],
        in_reply_to: nil,
        message_id: "<><><><><>",
        reply_to: [{nil, "foo@bar.com"}],
        sender: [{nil, "person@domain.com"}],
        subject: "An HTML email",
        to: [{nil, "bar@foo.com"}],
        from: [{"Aych T. Emmel", "person@domain.com"}]
      }

      assert Mail.from_yugo_type(yugo_msg) == %Mail{
               bcc: [],
               text_body: "_Wow!!_\r\n\r\nThis *email* has rich text!\r\n\r\n",
               html_body:
                 "<div id=\"geary-body\" dir=\"auto\"><u><font size=\"1\">Wow!!</font></u><div><br></div><div>This <b>email</b>&nbsp;has <font face=\"monospace\" color=\"#f5c211\">rich text</font><font face=\"sans\">!</font></div></div>",
               cc: [],
               date: ~U[2022-12-08 04:59:48Z],
               flags: [],
               in_reply_to: nil,
               message_id: "<><><><><>",
               reply_to: [{nil, "foo@bar.com"}],
               sender: "person@domain.com",
               subject: "An HTML email",
               to: [{nil, "bar@foo.com"}],
               from: [{"Aych T. Emmel", "person@domain.com"}]
             }
    end

    test "mail with neither html or text onpart bodies" do
      yugo_msg = %{
        bcc: [],
        body:
          {"text/x-elixir", %{"charset" => "us-ascii"},
           "defmodule Hello do\n  def greet do\n    :world\n  end\nend\n"},
        cc: [],
        date: ~U[2022-12-08 04:59:48Z],
        flags: [],
        in_reply_to: nil,
        message_id: "<><><><><>",
        reply_to: [{nil, "foo@bar.com"}],
        sender: [{nil, "person@domain.com"}],
        subject: "An HTML email",
        to: [{nil, "bar@foo.com"}],
        from: [{"Aych T. Emmel", "person@domain.com"}]
      }

      assert_raise RuntimeError, fn ->
        Mail.from_yugo_type(yugo_msg)
      end
    end

    test "mail with nested multipart text and html bodies" do
      yugo_msg = %{
        bcc: [],
        body: [
          [
            {"x-foo/x-bar", %{}, "this is 1.1"},
            {"x-foo/x-bar", %{}, "this is 1.2"},
            [
              {"x-foo/x-bar", %{}, "this is 1.3.1"},
              {"x-foo/x-bar", %{}, "this is 1.3.2"}
            ],
            {"text/html", %{"charset" => "us-ascii"},
             "<div id=\"geary-body\" dir=\"auto\"><u><font size=\"1\">Wow!!</font></u><div><br></div><div>This <b>email</b>&nbsp;has <font face=\"monospace\" color=\"#f5c211\">rich text</font><font face=\"sans\">!</font></div></div>"}
          ],
          {"text/plain", %{"charset" => "us-ascii"},
           "_Wow!!_\r\n\r\nThis *email* has rich text!\r\n\r\n"}
        ],
        cc: [],
        date: ~U[2022-12-08 04:59:48Z],
        flags: [],
        in_reply_to: nil,
        message_id: "<><><><><>",
        reply_to: [{nil, "foo@bar.com"}],
        sender: [{nil, "person@domain.com"}],
        subject: "An HTML email",
        to: [{nil, "bar@foo.com"}],
        from: [{"Aych T. Emmel", "person@domain.com"}]
      }

      assert Mail.from_yugo_type(yugo_msg) == %Mail{
               bcc: [],
               text_body: "_Wow!!_\r\n\r\nThis *email* has rich text!\r\n\r\n",
               html_body:
                 "<div id=\"geary-body\" dir=\"auto\"><u><font size=\"1\">Wow!!</font></u><div><br></div><div>This <b>email</b>&nbsp;has <font face=\"monospace\" color=\"#f5c211\">rich text</font><font face=\"sans\">!</font></div></div>",
               cc: [],
               date: ~U[2022-12-08 04:59:48Z],
               flags: [],
               in_reply_to: nil,
               message_id: "<><><><><>",
               reply_to: [{nil, "foo@bar.com"}],
               sender: "person@domain.com",
               subject: "An HTML email",
               to: [{nil, "bar@foo.com"}],
               from: [{"Aych T. Emmel", "person@domain.com"}]
             }
    end
  end
end
