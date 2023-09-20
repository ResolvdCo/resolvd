defmodule Resolvd.ConversationsTest do
  use Resolvd.DataCase

  alias Resolvd.Conversations

  describe "conversations" do
    alias Resolvd.Conversations.Conversation

    import Resolvd.ConversationsFixtures

    @invalid_attrs %{body: nil, subject: nil}

    test "list_conversations/0 returns all conversations" do
      conversation = conversation_fixture()
      assert Conversations.list_conversations() == [conversation]
    end

    test "get_conversation!/1 returns the conversation with given id" do
      conversation = conversation_fixture()
      assert Conversations.get_conversation!(conversation.id) == conversation
    end

    test "create_or_update_conversation_from_email/2 creates a new conversation and message" do
      email = %{
        bcc: [],
        body: [
          {"text/plain", %{"CHARSET" => "UTF-8"},
           "hello world!\r\n\r\nThanks,\r\nLuke Strickland\r\n"},
          {"text/html", %{"CHARSET" => "UTF-8"},
           "<div dir=\"ltr\"><div>hello world!</div><div><br></div><div><div><div dir=\"ltr\" class=\"gmail_signature\" data-smartmail=\"gmail_signature\"><div dir=\"ltr\"><font face=\"&#39;courier new&#39;, monospace\">Thanks,</font><div><font face=\"&#39;courier new&#39;, monospace\">Luke Strickland</font></div></div></div></div></div></div>\r\n"}
        ],
        cc: [],
        date: ~U[2023-05-13 03:36:19Z],
        flags: [],
        in_reply_to: nil,
        message_id: "<CAAEjmzzTjb6PUJvc3S351gRyZ699Hr5yPL-2s0ExjAvPrPT0Fg@mail.gmail.com>",
        reply_to: ["luke@axxim.net"],
        sender: ["luke@axxim.net"],
        subject: "One more test",
        to: ["resolvd@axxim.net"]
      }

      email = Resolvd.Mailboxes.Mail.from_yugo_type(email)

      {:ok, conversation} = Conversations.create_or_update_conversation_from_email(email)

      message = hd(conversation.messages)

      assert conversation.subject == "One more test"
      assert conversation.customer.name == "luke@axxim.net"
      assert message.customer.name == "luke@axxim.net"
    end

    test "create_conversation/1 with valid data creates a conversation" do
      valid_attrs = %{body: 42, subject: "some subject"}

      assert {:ok, %Conversation{} = conversation} =
               Conversations.create_conversation(valid_attrs)

      assert conversation.body == 42
      assert conversation.subject == "some subject"
    end

    test "create_conversation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Conversations.create_conversation(@invalid_attrs)
    end

    test "update_conversation/2 with valid data updates the conversation" do
      conversation = conversation_fixture()
      update_attrs = %{body: 43, subject: "some updated subject"}

      assert {:ok, %Conversation{} = conversation} =
               Conversations.update_conversation(conversation, update_attrs)

      assert conversation.body == 43
      assert conversation.subject == "some updated subject"
    end

    test "update_conversation/2 with invalid data returns error changeset" do
      conversation = conversation_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Conversations.update_conversation(conversation, @invalid_attrs)

      assert conversation == Conversations.get_conversation!(conversation.id)
    end

    test "delete_conversation/1 deletes the conversation" do
      conversation = conversation_fixture()
      assert {:ok, %Conversation{}} = Conversations.delete_conversation(conversation)
      assert_raise Ecto.NoResultsError, fn -> Conversations.get_conversation!(conversation.id) end
    end

    test "change_conversation/1 returns a conversation changeset" do
      conversation = conversation_fixture()
      assert %Ecto.Changeset{} = Conversations.change_conversation(conversation)
    end
  end

  describe "messages" do
    alias Resolvd.Conversations.Message

    import Resolvd.ConversationsFixtures

    @invalid_attrs %{body: nil}

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Conversations.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Conversations.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      valid_attrs = %{body: "some body"}

      assert {:ok, %Message{} = message} = Conversations.create_message(valid_attrs)
      assert message.body == "some body"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Conversations.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      update_attrs = %{body: "some updated body"}

      assert {:ok, %Message{} = message} = Conversations.update_message(message, update_attrs)
      assert message.body == "some updated body"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Conversations.update_message(message, @invalid_attrs)
      assert message == Conversations.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Conversations.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Conversations.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Conversations.change_message(message)
    end
  end
end
