defmodule ResolvdWeb.ConversationsLiveTest do
  use ResolvdWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resolvd.ConversationsFixtures
  import Resolvd.MailboxesFixtures, only: [mailbox_fixture: 1]
  import Resolvd.AccountsFixtures, only: [user_fixture: 1]
  import Swoosh.TestAssertions

  import ExUnit.CaptureLog, only: [capture_log: 1]

  setup :set_swoosh_global

  defp create_conversation(%{mailboxes: [mailbox | _], conversations: conversations} = other) do
    Map.put(other, :conversations, [conversation_fixture_mail(mailbox) | conversations])
  end

  defp create_conversation(%{mailboxes: [mailbox | _]} = other) do
    Map.put(other, :conversations, [conversation_fixture_mail(mailbox)])
  end

  defp create_conversation(%{admin: admin, conversations: conversations} = other) do
    Map.put(other, :conversations, [conversation_fixture_user(admin) | conversations])
  end

  defp create_conversation(%{admin: admin} = other) do
    Map.put(other, :conversations, [conversation_fixture_user(admin)])
  end

  defp create_mailbox(%{admin: admin, mailboxes: mailboxes} = other) do
    Map.put(other, :mailboxes, [mailbox_fixture(admin) | mailboxes])
  end

  defp create_mailbox(%{admin: admin} = other) do
    Map.put(other, :mailboxes, [mailbox_fixture(admin)])
  end

  defp create_user(%{admin: admin, users: users} = other) do
    Map.put(other, :users, [user_fixture(admin) | users])
  end

  defp create_user(%{admin: admin} = other) do
    Map.put(other, :users, [user_fixture(admin), admin])
  end

  describe "Index" do
    setup [
      :create_tenant_and_admin,
      :log_in_admin,
      :create_conversation,
      :create_conversation
    ]

    test "list all conversations", %{conn: conn, conversations: [con1, con2]} do
      {:ok, _index_live, html} = live(conn, ~p"/conversations")

      assert html =~ "Conversations"
      assert html =~ con1.subject
      assert html =~ "conversations-#{con1.id}"

      assert html =~ con2.subject
      assert html =~ "conversations-#{con2.id}"
    end

    test "display selected conversation", %{conn: conn, conversations: [con | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations")

      assert view |> element("#conversations-#{con.id}") |> render_click() =~ con.mailbox_id

      assert_patched(view, "/conversations?id=#{con.id}")
      assert page_title(view) =~ con.subject
    end

    test "switch to other conversation", %{conn: conn, conversations: [con1, con2]} do
      {:ok, view, _html} = live(conn, ~p"/conversations")

      assert view |> element("#conversations-#{con1.id}") |> render_click() =~ con1.mailbox_id

      assert_patched(view, "/conversations?id=#{con1.id}")
      assert page_title(view) =~ con1.subject

      assert view |> element("#conversations-#{con2.id}") |> render_click() =~ con2.mailbox_id

      assert_patched(view, "/conversations?id=#{con2.id}")
      assert page_title(view) =~ con2.subject
    end
  end

  describe "Assign conversation" do
    setup [
      :create_tenant_and_admin,
      :create_user,
      :log_in_admin,
      :create_mailbox,
      :create_mailbox,
      :create_conversation,
      :create_conversation
    ]

    test "no user assigned by default", %{conn: conn, conversations: [conversation | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations")

      assert view |> element("#conversations-#{conversation.id}") |> render_click() =~
               conversation.mailbox_id

      assert_patched(view, "/conversations?id=#{conversation.id}")
      assert page_title(view) =~ conversation.subject

      assert view |> element("#conversation-details") |> render() =~ "Not assigned"
    end

    test "replying assigns to user", %{
      conn: conn,
      conversations: [conversation | _],
      admin: user
    } do
      {:ok, view, _html} = live(conn, ~p"/conversations")

      assert view |> element("#conversations-#{conversation.id}") |> render_click() =~
               conversation.mailbox_id

      assert_patched(view, "/conversations?id=#{conversation.id}")
      assert page_title(view) =~ conversation.subject

      assert view |> element("#conversation-details") |> render() =~ "Not assigned"

      view |> element("#message-form") |> render_submit()
      assert_email_sent()
      assert view |> element("#conversation-details") |> render() =~ user.id
    end

    test "replying to assigned conversation doesn't reassign", %{
      conn: conn,
      conversations: [conversation | _],
      users: [user1, user2]
    } do
      conn = log_in_user(conn, user1)
      {:ok, view, _html} = live(conn, ~p"/conversations")

      assert view |> element("#conversations-#{conversation.id}") |> render_click() =~
               conversation.mailbox_id

      assert_patched(view, "/conversations?id=#{conversation.id}")
      assert page_title(view) =~ conversation.subject

      assert view |> element("#conversation-details") |> render() =~ "Not assigned"

      view |> element("#message-form") |> render_submit()
      assert_email_sent()
      assert view |> element("#conversation-details") |> render() =~ user1.id

      conn = log_in_user(conn, user2)
      {:ok, view, _html} = live(conn, ~p"/conversations")

      assert view |> element("#conversations-#{conversation.id}") |> render_click() =~
               conversation.mailbox_id

      assert_patched(view, "/conversations?id=#{conversation.id}")
      assert page_title(view) =~ conversation.subject

      assert view |> element("#conversation-details") |> render() =~ user1.id

      view |> element("#message-form") |> render_submit()
      assert_email_sent()
      assert view |> element("#conversation-details") |> render() =~ user1.id
    end

    test "assign to user", %{conn: conn, conversations: [conversation | _], users: [user | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations")

      assert view |> element("#conversations-#{conversation.id}") |> render_click() =~
               conversation.mailbox_id

      assert_patched(view, "/conversations?id=#{conversation.id}")
      assert page_title(view) =~ conversation.subject

      assert view |> element("#conversation-details") |> render() =~ "Not assigned"

      view |> element("#assignee-select") |> render_change(%{assignee: user.id})
      assert view |> element("#conversation-details") |> render() =~ user.id
    end

    test "reassign user", %{conn: conn, conversations: [conversation | _], users: [user1, user2]} do
      {:ok, view, _html} = live(conn, ~p"/conversations")

      assert view |> element("#conversations-#{conversation.id}") |> render_click() =~
               conversation.mailbox_id

      assert_patched(view, "/conversations?id=#{conversation.id}")
      assert page_title(view) =~ conversation.subject

      assert view |> element("#conversation-details") |> render() =~ "Not assigned"

      view |> element("#assignee-select") |> render_change(%{assignee: user1.id})
      assert view |> element("#conversation-details") |> render() =~ user1.id

      view |> element("#assignee-select") |> render_change(%{assignee: user2.id})
      assert view |> element("#conversation-details") |> render() =~ user2.id
    end

    test "unassign user", %{conn: conn, conversations: [conversation | _], users: [user1, user2]} do
      {:ok, view, _html} = live(conn, ~p"/conversations")

      assert view |> element("#conversations-#{conversation.id}") |> render_click() =~
               conversation.mailbox_id

      assert_patched(view, "/conversations?id=#{conversation.id}")
      assert page_title(view) =~ conversation.subject

      assert view |> element("#conversation-details") |> render() =~ "Not assigned"

      view |> element("#assignee-select") |> render_change(%{assignee: user1.id})
      assert view |> element("#conversation-details") |> render() =~ user1.id

      view |> element("#assignee-select") |> render_change(%{assignee: user2.id})
      assert view |> element("#conversation-details") |> render() =~ user2.id

      view |> element("#assignee-select") |> render_change(%{assignee: ""})
      assert view |> element("#conversation-details") |> render() =~ "Not assigned"
    end

    test "default mailbox", %{
      conn: conn,
      conversations: [conversation | _],
      mailboxes: [mailbox | _]
    } do
      {:ok, view, _html} = live(conn, ~p"/conversations")

      assert view |> element("#conversations-#{conversation.id}") |> render_click() =~
               conversation.mailbox_id

      assert_patched(view, "/conversations?id=#{conversation.id}")
      assert page_title(view) =~ conversation.subject

      assert view |> element("#conversation-details") |> render() =~ mailbox.id
    end

    test "assign mailbox", %{
      conn: conn,
      conversations: [conversation | _],
      mailboxes: [mailbox1, mailbox2]
    } do
      {:ok, view, _html} = live(conn, ~p"/conversations")

      assert view |> element("#conversations-#{conversation.id}") |> render_click() =~
               conversation.mailbox_id

      assert_patched(view, "/conversations?id=#{conversation.id}")
      assert page_title(view) =~ conversation.subject

      assert view |> element("#conversation-details") |> render() =~ mailbox1.id

      view |> element("#mailbox-select") |> render_change(%{mailbox: mailbox2.id})
      assert view |> element("#conversation-details") |> render() =~ mailbox2.id
    end

    test "reassign mailbox", %{
      conn: conn,
      conversations: [conversation | _],
      mailboxes: [mailbox1, mailbox2]
    } do
      {:ok, view, _html} = live(conn, ~p"/conversations")

      assert view |> element("#conversations-#{conversation.id}") |> render_click() =~
               conversation.mailbox_id

      assert_patched(view, "/conversations?id=#{conversation.id}")
      assert page_title(view) =~ conversation.subject

      assert view |> element("#conversation-details") |> render() =~ mailbox1.id

      view |> element("#mailbox-select") |> render_change(%{mailbox: mailbox2.id})
      assert view |> element("#conversation-details") |> render() =~ mailbox2.id

      view |> element("#mailbox-select") |> render_change(%{mailbox: mailbox1.id})
      assert view |> element("#conversation-details") |> render() =~ mailbox1.id
    end

    test "unassign mailbox", %{
      conn: conn,
      conversations: [conversation | _],
      mailboxes: [mailbox1 | _]
    } do
      {:ok, view, _html} = live(conn, ~p"/conversations")

      assert view |> element("#conversations-#{conversation.id}") |> render_click() =~
               conversation.mailbox_id

      assert_patched(view, "/conversations?id=#{conversation.id}")
      assert page_title(view) =~ conversation.subject

      assert view |> element("#conversation-details") |> render() =~ mailbox1.id

      assert capture_log(fn ->
               Process.flag(:trap_exit, true)
               catch_exit(view |> element("#mailbox-select") |> render_change(%{mailbox: ""}))
             end) =~ "Ecto.Query.CastError"
    end
  end

  describe "Conversation status" do
    setup [
      :create_tenant_and_admin,
      :create_user,
      :log_in_admin,
      :create_mailbox,
      :create_mailbox,
      :create_conversation,
      :create_conversation
    ]

    test "initial status", %{conn: conn, conversations: [conversation | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations?id=#{conversation.id}")

      assert view |> element("#conversation-details") |> render() =~ "Open"
    end

    test "prioritize conversation", %{conn: conn, conversations: [conversation | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations?id=#{conversation.id}")

      assert view |> element("#conversation-details") |> render() =~ "Open"

      view |> element("#priority-change") |> render_change(%{priority: true})
      assert view |> element("#conversation-details") |> render() =~ "Prioritized"
    end

    test "toggle priority", %{conn: conn, conversations: [conversation | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations?id=#{conversation.id}")

      assert view |> element("#conversation-details") |> render() =~ "Open"

      view |> element("#priority-change") |> render_change(%{priority: true})
      assert view |> element("#conversation-details") |> render() =~ "Prioritized"

      view |> element("#priority-change") |> render_change(%{priority: false})
      assert view |> element("#conversation-details") |> render() =~ "Open"

      view |> element("#priority-change") |> render_change(%{priority: true})
      assert view |> element("#conversation-details") |> render() =~ "Prioritized"
    end

    test "mark resolved from open", %{conn: conn, conversations: [conversation | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations?id=#{conversation.id}")

      assert view |> element("#conversation-details") |> render() =~ "Open"

      view |> element("#resolve-change") |> render_change(%{resolve: true})
      assert view |> element("#conversation-details") |> render() =~ "Resolved"
    end

    test "toggle resolved from open", %{conn: conn, conversations: [conversation | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations?id=#{conversation.id}")

      assert view |> element("#conversation-details") |> render() =~ "Open"

      view |> element("#resolve-change") |> render_change(%{resolve: true})
      assert view |> element("#conversation-details") |> render() =~ "Resolved"

      view |> element("#resolve-change") |> render_change(%{resolve: false})
      assert view |> element("#conversation-details") |> render() =~ "Open"

      view |> element("#resolve-change") |> render_change(%{resolve: true})
      assert view |> element("#conversation-details") |> render() =~ "Resolved"
    end

    test "mark resolved from prioritized", %{conn: conn, conversations: [conversation | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations?id=#{conversation.id}")

      assert view |> element("#conversation-details") |> render() =~ "Open"

      view |> element("#priority-change") |> render_change(%{priority: true})
      assert view |> element("#conversation-details") |> render() =~ "Prioritized"

      view |> element("#resolve-change") |> render_change(%{resolve: true})
      assert view |> element("#conversation-details") |> render() =~ "Resolved"
    end

    test "mark prioritized from resolved", %{conn: conn, conversations: [conversation | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations?id=#{conversation.id}")

      assert view |> element("#conversation-details") |> render() =~ "Open"

      view |> element("#resolve-change") |> render_change(%{resolve: true})
      assert view |> element("#conversation-details") |> render() =~ "Resolved"

      view |> element("#priority-change") |> render_change(%{priority: true})
      assert view |> element("#conversation-details") |> render() =~ "Resolved"
    end

    test "toggle resolved and prioritized", %{conn: conn, conversations: [conversation | _]} do
      {:ok, view, _html} = live(conn, ~p"/conversations?id=#{conversation.id}")

      assert view |> element("#conversation-details") |> render() =~ "Open"

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
      assert view |> element("#conversation-details") |> render() =~ "Open"
    end
  end
end