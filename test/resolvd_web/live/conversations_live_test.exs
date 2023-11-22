defmodule ResolvdWeb.ConversationsLiveTest do
  use ResolvdWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resolvd.ConversationsFixtures
  import Resolvd.MailboxesFixtures, only: [mailbox_fixture: 1]
  import Resolvd.AccountsFixtures, only: [user_fixture: 1]
  import Swoosh.TestAssertions

  import ExUnit.CaptureLog, only: [capture_log: 1]

  setup :set_swoosh_global

  defp create_conversations(%{mailboxes: mailboxes} = other) do
    conversations =
      Enum.flat_map(mailboxes, fn mailbox ->
        for _ <- 1..5, do: conversation_fixture_mail(mailbox)
      end)

    Map.put(other, :conversations, conversations)
  end

  defp create_conversations(%{users: users} = other) do
    conversations =
      Enum.flat_map(users, fn user ->
        for _ <- 1..5, do: conversation_fixture_user(user)
      end)

    Map.put(other, :conversations, conversations)
  end

  defp create_conversations(%{user: user} = other) do
    conversations = for _ <- 1..5, do: conversation_fixture_user(user)

    Map.put(other, :conversations, conversations)
  end

  defp create_mailboxes(%{admin: admin} = other) do
    mailboxes = for _ <- 1..5, do: mailbox_fixture(admin)
    Map.put(other, :mailboxes, mailboxes)
  end

  defp create_users(%{admin: admin} = other) do
    users = for _ <- 1..5, do: user_fixture(admin)
    Map.put(other, :users, users)
  end

  describe "Index" do
    setup [
      :create_tenant_and_admin,
      :log_in_admin,
      :create_conversations
    ]

    test "list all conversations", %{conn: conn, conversations: conversations} do
      assert {:error, {:live_redirect, %{to: "/conversations/all"}}} =
               live(conn, ~p"/conversations")

      assert {:error, {:live_redirect, %{to: conversation_path}}} =
               live(conn, ~p"/conversations/all")

      {:ok, _index_live, html} = live(conn, conversation_path)

      assert html =~ "Conversations"

      Enum.each(conversations, fn conversation ->
        assert html =~ conversation.subject
        assert html =~ "conversations-#{conversation.id}"
      end)
    end

    test "display selected conversation", %{conn: conn, conversations: [con | _]} do
      assert {:error, {:live_redirect, %{to: conversation_path}}} =
               live(conn, ~p"/conversations/all")

      {:ok, view, _html} = live(conn, conversation_path)

      assert view |> element("#conversations-#{con.id}") |> render_click() =~ con.mailbox_id

      assert_patched(view, "/conversations/all?id=#{con.id}")
      assert page_title(view) =~ con.subject
    end

    test "switch to other conversation", %{conn: conn, conversations: [con1, con2 | _]} do
      assert {:error, {:live_redirect, %{to: all_conversations}}} =
               live(conn, ~p"/conversations")

      assert {:error, {:live_redirect, %{to: conversation_path}}} =
               live(conn, all_conversations)

      {:ok, view, _html} = live(conn, conversation_path)

      assert view |> element("#conversations-#{con1.id}") |> render_click() =~ con1.mailbox_id

      assert_patched(view, "/conversations/all?id=#{con1.id}")
      assert page_title(view) =~ con1.subject

      assert view |> element("#conversations-#{con2.id}") |> render_click() =~ con2.mailbox_id

      assert_patched(view, "/conversations/all?id=#{con2.id}")
      assert page_title(view) =~ con2.subject
    end
  end

  describe "Assign conversation" do
    setup [
      :create_tenant_and_admin,
      :create_users,
      :log_in_admin,
      :create_mailboxes,
      :create_conversations
    ]

    test "no user assigned by default", %{conn: conn, conversations: [conversation | _]} do
      assert {:error, {:live_redirect, %{to: all_conversations}}} =
               live(conn, ~p"/conversations")

      assert {:error, {:live_redirect, %{to: conversation_path}}} =
               live(conn, all_conversations)

      {:ok, view, _html} = live(conn, conversation_path)

      assert view |> element("#conversations-#{conversation.id}") |> render_click() =~
               conversation.mailbox_id

      assert_patched(view, "/conversations/all?id=#{conversation.id}")
      assert page_title(view) =~ conversation.subject

      assert view |> element("#conversation-details") |> render() =~ "Not assigned"
    end

    test "replying assigns to user", %{
      conn: conn,
      conversations: [conversation | _],
      admin: user
    } do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation.id}")

      assert page_title(view) =~ conversation.subject

      view |> element("#message-form") |> render_submit()
      assert_email_sent()
      assert view |> element("#conversation-details") |> render() =~ user.name
    end

    test "replying to assigned conversation doesn't reassign", %{
      conn: conn,
      conversations: [conversation | _],
      users: [user1, user2 | _]
    } do
      conn = log_in_user(conn, user1)

      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation.id}")

      assert page_title(view) =~ conversation.subject

      view |> element("#message-form") |> render_submit()
      assert_email_sent()
      assert view |> element("#conversation-details") |> render() =~ user1.name

      conn = log_in_user(conn, user2)

      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation.id}")

      assert page_title(view) =~ conversation.subject
      assert view |> element("#conversation-details") |> render() =~ user1.name

      view |> element("#message-form") |> render_submit()
      assert_email_sent()
      assert view |> element("#conversation-details") |> render() =~ user1.name
    end

    test "assign to user", %{conn: conn, conversations: [conversation | _], users: [user | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation.id}")

      assert page_title(view) =~ conversation.subject
      assert view |> element("#conversation-details") |> render() =~ "Not assigned"

      view |> element("#assignee-select") |> render_change(%{assignee: user.id})
      assert view |> element("#conversation-details") |> render() =~ user.name
    end

    test "reassign user", %{conn: conn, conversations: [conversation | _], users: users} do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation.id}")

      assert page_title(view) =~ conversation.subject
      assert view |> element("#conversation-details") |> render() =~ "Not assigned"

      Enum.each(users, fn user ->
        view |> element("#assignee-select") |> render_change(%{assignee: user.id})
        assert view |> element("#conversation-details") |> render() =~ user.name
      end)
    end

    test "unassign user", %{
      conn: conn,
      conversations: [conversation | _],
      users: [user | _]
    } do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation.id}")

      assert page_title(view) =~ conversation.subject
      assert view |> element("#conversation-details") |> render() =~ "Not assigned"

      view |> element("#assignee-select") |> render_change(%{assignee: user.id})
      assert view |> element("#conversation-details") |> render() =~ user.name

      view |> element("#assignee-select") |> render_change(%{assignee: ""})
      assert view |> element("#conversation-details") |> render() =~ "Not assigned"
    end

    test "default mailbox", %{
      conn: conn,
      conversations: [conversation | _],
      mailboxes: [mailbox | _]
    } do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation.id}")

      assert page_title(view) =~ conversation.subject
      assert view |> element("#conversation-details") |> render() =~ mailbox.name
    end

    test "reassign mailbox", %{
      conn: conn,
      conversations: [conversation | _],
      mailboxes: [mailbox | mailboxes]
    } do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation.id}")

      assert page_title(view) =~ conversation.subject
      assert view |> element("#conversation-details") |> render() =~ mailbox.name

      Enum.each(mailboxes, fn mb ->
        view |> element("#mailbox-select") |> render_change(%{mailbox: mb.id})
        assert view |> element("#conversation-details") |> render() =~ mb.name
      end)
    end

    test "unassign mailbox", %{
      conn: conn,
      conversations: [conversation | _],
      mailboxes: [mailbox | _]
    } do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation.id}")

      assert page_title(view) =~ conversation.subject
      assert view |> element("#conversation-details") |> render() =~ mailbox.name

      assert capture_log(fn ->
               Process.flag(:trap_exit, true)
               catch_exit(view |> element("#mailbox-select") |> render_change(%{mailbox: ""}))
             end) =~ "Ecto.Query.CastError"
    end
  end

  describe "Conversation status" do
    setup [
      :create_tenant_and_admin,
      :create_users,
      :log_in_admin,
      :create_mailboxes,
      :create_conversations
    ]

    test "initial status", %{conn: conn, conversations: [conversation | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation}")

      assert view |> element("#conversation-details") |> render() =~ "Unresolved"
    end

    test "prioritize conversation", %{conn: conn, conversations: [conversation | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation}")

      assert view |> element("#conversation-details") |> render() =~ "Unresolved"

      view |> element("#priority-change") |> render_change(%{priority: true})
      assert view |> element("#conversation-details") |> render() =~ "Prioritized"
    end

    test "toggle priority", %{conn: conn, conversations: [conversation | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation}")

      assert view |> element("#conversation-details") |> render() =~ "Unresolved"

      view |> element("#priority-change") |> render_change(%{priority: true})
      assert view |> element("#conversation-details") |> render() =~ "Prioritized"

      view |> element("#priority-change") |> render_change(%{priority: false})
      assert view |> element("#conversation-details") |> render() =~ "Unresolved"

      view |> element("#priority-change") |> render_change(%{priority: true})
      assert view |> element("#conversation-details") |> render() =~ "Prioritized"
    end

    test "mark resolved from open", %{conn: conn, conversations: [conversation | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation}")

      assert view |> element("#conversation-details") |> render() =~ "Unresolved"

      view |> element("#resolve-change") |> render_change(%{resolve: true})
      assert view |> element("#conversation-details") |> render() =~ "Resolved"
    end

    test "toggle resolved from open", %{conn: conn, conversations: [conversation | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation}")

      assert view |> element("#conversation-details") |> render() =~ "Unresolved"

      view |> element("#resolve-change") |> render_change(%{resolve: true})
      assert view |> element("#conversation-details") |> render() =~ "Resolved"

      view |> element("#resolve-change") |> render_change(%{resolve: false})
      assert view |> element("#conversation-details") |> render() =~ "Unresolved"

      view |> element("#resolve-change") |> render_change(%{resolve: true})
      assert view |> element("#conversation-details") |> render() =~ "Resolved"
    end

    test "mark resolved from prioritized", %{conn: conn, conversations: [conversation | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation}")

      assert view |> element("#conversation-details") |> render() =~ "Unresolved"

      view |> element("#priority-change") |> render_change(%{priority: true})
      assert view |> element("#conversation-details") |> render() =~ "Prioritized"

      view |> element("#resolve-change") |> render_change(%{resolve: true})
      assert view |> element("#conversation-details") |> render() =~ "Resolved"
    end

    test "mark prioritized from resolved", %{conn: conn, conversations: [conversation | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation}")

      assert view |> element("#conversation-details") |> render() =~ "Unresolved"

      view |> element("#resolve-change") |> render_change(%{resolve: true})
      assert view |> element("#conversation-details") |> render() =~ "Resolved"

      view |> element("#priority-change") |> render_change(%{priority: true})
      assert view |> element("#conversation-details") |> render() =~ "Resolved"
    end

    test "toggle resolved and prioritized", %{conn: conn, conversations: [conversation | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation}")

      assert view |> element("#conversation-details") |> render() =~ "Unresolved"

      view |> element("#priority-change") |> render_change(%{priority: true})
      assert view |> element("#conversation-details") |> render() =~ "Prioritized"

      view |> element("#resolve-change") |> render_change(%{resolve: true})
      assert view |> element("#conversation-details") |> render() =~ "Resolved"

      view |> element("#priority-change") |> render_change(%{priority: false})
      assert view |> element("#conversation-details") |> render() =~ "Resolved"

      view |> element("#priority-change") |> render_change(%{priority: true})
      assert view |> element("#conversation-details") |> render() =~ "Resolved"

      view |> element("#resolve-change") |> render_change(%{resolve: false})
      assert view |> element("#conversation-details") |> render() =~ "Prioritized"

      view |> element("#priority-change") |> render_change(%{priority: false})
      assert view |> element("#conversation-details") |> render() =~ "Unresolved"
    end
  end

  describe "Initial Conversation Categories" do
    setup [
      :create_tenant_and_admin,
      :log_in_admin,
      :create_conversations
    ]

    test "all conversations", %{conn: conn, conversations: [conversation | _] = conversations} do
      {:ok, _view, html} = live(conn, ~p"/conversations/all?id=#{conversation}")

      assert html =~ "All Conversations"

      Enum.each(conversations, fn convo ->
        assert html =~ convo.subject
        assert html =~ "conversations-#{convo.id}"
      end)
    end

    test "my conversations", %{conn: conn, conversations: conversations} do
      {:ok, _view, html} = live(conn, ~p"/conversations/me")

      assert html =~ "My Conversations"

      Enum.each(conversations, fn convo ->
        refute html =~ convo.subject
        refute html =~ "conversations-#{convo.id}"
      end)
    end

    test "unassigned conversations", %{
      conn: conn,
      conversations: [conversation | _] = conversations
    } do
      {:ok, _view, html} = live(conn, ~p"/conversations/unassigned?id=#{conversation}")

      assert html =~ "Unassigned Conversations"

      Enum.each(conversations, fn convo ->
        assert html =~ convo.subject
        assert html =~ "conversations-#{convo.id}"
      end)
    end

    test "prioritized conversations", %{conn: conn, conversations: conversations} do
      {:ok, _view, html} = live(conn, ~p"/conversations/prioritized")

      assert html =~ "Prioritized Conversations"

      Enum.each(conversations, fn convo ->
        refute html =~ convo.subject
        refute html =~ "conversations-#{convo.id}"
      end)
    end

    test "resolved conversations", %{conn: conn, conversations: conversations} do
      {:ok, _view, html} = live(conn, ~p"/conversations/resolved")

      assert html =~ "Resolved Conversations"

      Enum.each(conversations, fn convo ->
        refute html =~ convo.subject
        refute html =~ "conversations-#{convo.id}"
      end)
    end
  end

  describe "Filter conversations" do
    setup [
      :create_tenant_and_admin,
      :log_in_admin,
      :create_conversations
    ]

    test "to me", %{conn: conn, conversations: [conversation | others], admin: user} do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation}")

      view |> element("#assignee-select") |> render_change(%{assignee: user.id})
      assert view |> element("#conversation-details") |> render() =~ user.name

      view |> element("#category-me") |> render_click()
      {"/conversations/me", _flash} = assert_redirect(view)
      {:error, {:live_redirect, %{to: path}}} = live(conn, "/conversations/me")

      {:ok, view, _html} = live(conn, path)

      assert view |> element("#heading") |> render() =~ "My Conversations"

      conversations_view = view |> element("#mailbox-filtered") |> render()

      assert conversations_view =~ conversation.subject
      assert conversations_view =~ "conversations-#{conversation.id}"

      Enum.each(others, fn convo ->
        refute conversations_view =~ convo.subject
        refute conversations_view =~ "conversations-#{convo.id}"
      end)
    end

    test "to unassigned", %{conn: conn, conversations: [conversation | others], admin: user} do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation}")

      view |> element("#assignee-select") |> render_change(%{assignee: user.id})
      assert view |> element("#conversation-details") |> render() =~ user.name

      view |> element("#category-unassigned") |> render_click()
      {"/conversations/unassigned", _flash} = assert_redirect(view)
      {:error, {:live_redirect, %{to: path}}} = live(conn, "/conversations/unassigned")

      {:ok, view, _html} = live(conn, path)

      assert view |> element("#heading") |> render() =~ "Unassigned Conversations"

      conversations_view = view |> element("#mailbox-filtered") |> render()

      Enum.each(others, fn convo ->
        assert conversations_view =~ convo.subject
        assert conversations_view =~ "conversations-#{convo.id}"
      end)

      refute conversations_view =~ conversation.subject
      refute conversations_view =~ "conversations-#{conversation.id}"
    end

    test "to prioritized", %{conn: conn, conversations: [conversation | others]} do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation}")

      view |> element("#priority-change") |> render_change(%{priority: true})
      assert view |> element("#conversation-details") |> render() =~ "Prioritized"

      view |> element("#category-prioritized") |> render_click()
      {"/conversations/prioritized", _flash} = assert_redirect(view)
      {:error, {:live_redirect, %{to: path}}} = live(conn, "/conversations/prioritized")

      {:ok, view, _html} = live(conn, path)

      assert view |> element("#heading") |> render() =~ "Prioritized Conversations"

      conversations_view = view |> element("#mailbox-filtered") |> render()

      assert conversations_view =~ conversation.subject
      assert conversations_view =~ "conversations-#{conversation.id}"

      Enum.each(others, fn convo ->
        refute conversations_view =~ convo.subject
        refute conversations_view =~ "conversations-#{convo.id}"
      end)
    end

    test "to resolved", %{conn: conn, conversations: [conversation | others]} do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation}")

      view |> element("#resolve-change") |> render_change(%{resolve: true})
      assert view |> element("#conversation-details") |> render() =~ "Resolved"

      view |> element("#category-resolved") |> render_click()
      {"/conversations/resolved", _flash} = assert_redirect(view)
      {:error, {:live_redirect, %{to: path}}} = live(conn, "/conversations/resolved")

      {:ok, view, _html} = live(conn, path)

      assert view |> element("#heading") |> render() =~ "Resolved Conversations"

      conversations_view = view |> element("#mailbox-filtered") |> render()

      assert conversations_view =~ conversation.subject
      assert conversations_view =~ "conversations-#{conversation.id}"

      Enum.each(others, fn convo ->
        refute conversations_view =~ convo.subject
        refute conversations_view =~ "conversations-#{convo.id}"
      end)
    end

    test "to all", %{conn: conn, conversations: [conversation | others]} do
      {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation}")

      view |> element("#resolve-change") |> render_change(%{resolve: true})
      assert view |> element("#conversation-details") |> render() =~ "Resolved"

      view |> element("#category-resolved") |> render_click()
      {"/conversations/resolved", _flash} = assert_redirect(view)
      {:error, {:live_redirect, %{to: path}}} = live(conn, "/conversations/resolved")

      {:ok, view, _html} = live(conn, path)

      assert view |> element("#heading") |> render() =~ "Resolved Conversations"

      conversations_view = view |> element("#mailbox-filtered") |> render()

      assert conversations_view =~ conversation.subject
      assert conversations_view =~ "conversations-#{conversation.id}"

      view |> element("#category-all") |> render_click()
      {"/conversations/all", _flash} = assert_redirect(view)
      {:error, {:live_redirect, %{to: path}}} = live(conn, "/conversations/all")

      {:ok, view, _html} = live(conn, path)

      assert view |> element("#heading") |> render() =~ "All Conversations"

      conversations_view = view |> element("#mailbox-filtered") |> render()

      refute conversations_view =~ conversation.subject
      refute conversations_view =~ "conversations-#{conversation.id}"

      Enum.each(others, fn convo ->
        assert conversations_view =~ convo.subject
        assert conversations_view =~ "conversations-#{convo.id}"
      end)
    end
  end

  describe "Search conversations" do
    setup [
      :create_tenant_and_admin,
      :log_in_admin,
      :create_mailboxes,
      :create_conversations
    ]

    test "by subject", %{conn: conn, conversations: conversations} do
      [conversation | others] = Enum.shuffle(conversations)

      assert {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation}")

      conversations_view = view |> element("#mailbox-filtered") |> render()

      Enum.each(conversations, fn convo ->
        assert conversations_view =~ convo.subject
        assert conversations_view =~ "conversations-#{convo.id}"
      end)

      view |> element("#conversation-search") |> render_change(%{query: conversation.subject})
      conversations_view = view |> element("#mailbox-filtered") |> render()

      assert conversations_view =~ conversation.subject
      assert conversations_view =~ "conversations-#{conversation.id}"

      Enum.each(others, fn convo ->
        if convo.mailbox_id != conversation.mailbox_id do
          refute conversations_view =~ convo.subject
          refute conversations_view =~ "conversations-#{convo.id}"
        end
      end)
    end

    test "by html_body", %{conn: conn, conversations: conversations} do
      [conversation | others] = Enum.shuffle(conversations)

      assert {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation}")

      message = conversation.messages |> List.first()

      view |> element("#conversation-search") |> render_change(%{query: message.html_body})
      conversations_view = view |> element("#mailbox-filtered") |> render()

      assert conversations_view =~ conversation.subject
      assert conversations_view =~ "conversations-#{conversation.id}"

      Enum.each(others, fn convo ->
        if convo.mailbox_id != conversation.mailbox_id do
          refute conversations_view =~ convo.subject
          refute conversations_view =~ "conversations-#{convo.id}"
        end
      end)
    end

    test "by text_body", %{conn: conn, conversations: conversations} do
      [conversation | others] = Enum.shuffle(conversations)

      assert {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation}")

      message = conversation.messages |> List.first()

      view |> element("#conversation-search") |> render_change(%{query: message.text_body})
      conversations_view = view |> element("#mailbox-filtered") |> render()

      assert conversations_view =~ conversation.subject
      assert conversations_view =~ "conversations-#{conversation.id}"

      Enum.each(others, fn convo ->
        if convo.mailbox_id != conversation.mailbox_id do
          refute conversations_view =~ convo.subject
          refute conversations_view =~ "conversations-#{convo.id}"
        end
      end)
    end

    test "when no match", %{conn: conn, conversations: conversations} do
      [conversation | _] = Enum.shuffle(conversations)

      assert {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation}")

      view |> element("#conversation-search") |> render_change(%{query: "Abrakadabra"})
      conversations_view = view |> element("#mailbox-filtered") |> render()

      Enum.each(conversations, fn convo ->
        refute conversations_view =~ convo.subject
        refute conversations_view =~ "conversations-#{convo.id}"
      end)
    end

    test "clear query", %{conn: conn, conversations: conversations} do
      [conversation | _] = Enum.shuffle(conversations)

      assert {:ok, view, _html} = live(conn, ~p"/conversations/all?id=#{conversation}")

      view |> element("#conversation-search") |> render_change(%{query: "Abrakadabra"})
      conversations_view = view |> element("#mailbox-filtered") |> render()

      Enum.each(conversations, fn convo ->
        refute conversations_view =~ convo.subject
        refute conversations_view =~ "conversations-#{convo.id}"
      end)

      view |> element("#conversation-search") |> render_change(%{query: ""})
      conversations_view = view |> element("#mailbox-filtered") |> render()

      Enum.each(conversations, fn convo ->
        assert conversations_view =~ convo.subject
        assert conversations_view =~ "conversations-#{convo.id}"
      end)
    end
  end
end
