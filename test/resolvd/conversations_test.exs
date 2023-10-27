defmodule Resolvd.ConversationsTest do
  use Resolvd.DataCase

  import Resolvd.ConversationsFixtures
  import Resolvd.MailboxesFixtures
  import Resolvd.AccountsFixtures

  alias Resolvd.Conversations

  describe "Conversation creation" do
    setup do
      %{user: user_fixture()}
    end

    test "create conversation from user", %{user: user} do
      # Conversation needs a mailbox to be created under the same tenant
      assert mailbox_fixture(user)

      {:ok, conversation} =
        Conversations.create_conversation(
          user,
          unique_message_email(),
          unique_conversation_subject(),
          valid_text_body()
        )

      assert conversation.tenant_id == user.tenant_id
    end

    test "create conversation from mail", %{user: user} do
      email = mail_fixture()
      mailbox = mailbox_fixture(user)

      {:ok, conversation} = Conversations.create_or_update_conversation_from_email(mailbox, email)

      assert conversation.mailbox_id == mailbox.id
    end

    test "customer name from email", %{user: user} do
      email = mail_fixture()
      mailbox = mailbox_fixture(user)

      {:ok, conversation} = Conversations.create_or_update_conversation_from_email(mailbox, email)

      assert conversation.mailbox_id == mailbox.id
      assert conversation.customer.name == email.from |> hd |> elem(0)
    end
  end

  describe "User assignment" do
    setup do
      admin = user_fixture()
      %{conversation: conversation_fixture_user(admin), admin: admin, user: user_fixture(admin)}
    end

    test "new conversations have no assigned user", %{conversation: conversation} do
      assert conversation.user_id == nil
    end

    test "replying assigns conversatoin to user", %{conversation: conversation, admin: admin} do
      {_message, conversation} =
        Conversations.create_message(conversation, admin, valid_message_attrs())

      assert conversation.user_id == admin.id
    end

    test "replying to already assigned conversatoin doesn't reassign", %{
      conversation: conversation,
      admin: admin,
      user: user
    } do
      {_message, conversation} =
        Conversations.create_message(conversation, admin, valid_message_attrs())

      assert conversation.user_id == admin.id

      Conversations.create_message(conversation, user, valid_message_attrs())

      assert conversation.user_id == admin.id
      assert conversation.user_id != user.id
    end

    test "reassign to user manually", %{
      conversation: conversation,
      admin: admin,
      user: user
    } do
      {_message, conversation} =
        Conversations.create_message(conversation, admin, valid_message_attrs())

      assert conversation.user_id == admin.id

      conversation = Conversations.update_conversation_user(conversation, user)
      assert conversation.user_id != admin.id
      assert conversation.user_id == user.id
    end

    test "reassign to user different users", %{
      conversation: conversation,
      admin: admin,
      user: user
    } do
      {_message, conversation} =
        Conversations.create_message(conversation, admin, valid_message_attrs())

      assert conversation.user_id == admin.id

      conversation = Conversations.update_conversation_user(conversation, user)
      assert conversation.user_id != admin.id
      assert conversation.user_id == user.id

      conversation = Conversations.update_conversation_user(conversation, admin)
      assert conversation.user_id != user.id
      assert conversation.user_id == admin.id
    end

    test "change to not assigned", %{
      conversation: conversation,
      admin: admin,
      user: user
    } do
      {_message, conversation} =
        Conversations.create_message(conversation, admin, valid_message_attrs())

      assert conversation.user_id == admin.id

      conversation = Conversations.update_conversation_user(conversation, user)
      assert conversation.user_id != admin.id
      assert conversation.user_id == user.id

      conversation = Conversations.update_conversation_user(conversation, nil)
      assert conversation.user_id != user.id
      assert conversation.user_id == nil
    end
  end

  describe "Associated mailbox" do
    setup do
      user = user_fixture()
      %{user: user, mailbox_one: mailbox_fixture(user), mailbox_two: mailbox_fixture(user)}
    end

    test "default set from mailbox received on", %{mailbox_one: mailbox} do
      email = mail_fixture()
      {:ok, conversation} = Conversations.create_or_update_conversation_from_email(mailbox, email)

      assert conversation.mailbox_id == mailbox.id
    end

    test "change associated mailbox", %{mailbox_one: mailbox_one, mailbox_two: mailbox_two} do
      conversation = conversation_fixture_mail(mailbox_one)
      assert conversation.mailbox_id == mailbox_one.id

      conversation = Conversations.update_conversation_mailbox(conversation, mailbox_two)
      assert conversation.mailbox_id != mailbox_one.id
      assert conversation.mailbox_id == mailbox_two.id
    end

    test "change associated mailbox back", %{mailbox_one: mailbox_one, mailbox_two: mailbox_two} do
      conversation = conversation_fixture_mail(mailbox_one)
      assert conversation.mailbox_id == mailbox_one.id

      conversation = Conversations.update_conversation_mailbox(conversation, mailbox_two)
      assert conversation.mailbox_id != mailbox_one.id
      assert conversation.mailbox_id == mailbox_two.id

      conversation = Conversations.update_conversation_mailbox(conversation, mailbox_one)
      assert conversation.mailbox_id != mailbox_two.id
      assert conversation.mailbox_id == mailbox_one.id
    end
  end

  describe "Conversation status" do
    setup do
      %{conversation: conversation_fixture_user()}
    end

    test "initial status", %{conversation: conversation} do
      assert conversation.is_resolved == false
      assert conversation.is_prioritized == false
    end

    test "mark as resolved", %{conversation: conversation} do
      assert conversation.is_resolved == false
      assert conversation.is_prioritized == false

      conversation = Conversations.set_resolved(conversation, true)
      assert conversation.is_resolved == true
    end

    test "toggle resolved status", %{conversation: conversation} do
      assert conversation.is_resolved == false
      assert conversation.is_prioritized == false

      conversation = Conversations.set_resolved(conversation, true)
      assert conversation.is_resolved == true

      conversation = Conversations.set_resolved(conversation, false)
      assert conversation.is_resolved == false

      conversation = Conversations.set_resolved(conversation, true)
      assert conversation.is_resolved == true
    end

    test "prioritize conversation", %{conversation: conversation} do
      assert conversation.is_resolved == false
      assert conversation.is_prioritized == false

      conversation = Conversations.set_priority(conversation, true)
      assert conversation.is_prioritized == true
    end

    test "toggle priority", %{conversation: conversation} do
      assert conversation.is_resolved == false
      assert conversation.is_prioritized == false

      conversation = Conversations.set_priority(conversation, true)
      assert conversation.is_prioritized == true

      conversation = Conversations.set_priority(conversation, false)
      assert conversation.is_prioritized == false

      conversation = Conversations.set_priority(conversation, true)
      assert conversation.is_prioritized == true
    end
  end
end
