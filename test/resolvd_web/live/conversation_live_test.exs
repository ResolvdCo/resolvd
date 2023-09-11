defmodule ResolvdWeb.ConversationLiveTest do
  use ResolvdWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resolvd.ConversationsFixtures

  @create_attrs %{body: 42, subject: "some subject"}
  @update_attrs %{body: 43, subject: "some updated subject"}
  @invalid_attrs %{body: nil, subject: nil}

  defp create_conversation(_) do
    conversation = conversation_fixture()
    %{conversation: conversation}
  end

  describe "Index" do
    setup [:create_conversation]

    test "lists all conversations", %{conn: conn, conversation: conversation} do
      {:ok, _index_live, html} = live(conn, ~p"/conversations")

      assert html =~ "Conversations"
      assert html =~ conversation.subject
    end

    test "saves new conversation", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/conversations")

      assert index_live |> element("a", "New Conversation") |> render_click() =~
               "New Conversation"

      assert_patch(index_live, ~p"/conversations/new")

      assert index_live
             |> form("#conversation-form", conversation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#conversation-form", conversation: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/conversations")

      html = render(index_live)
      assert html =~ "Conversation created successfully"
      assert html =~ "some subject"
    end

    test "updates conversation in listing", %{conn: conn, conversation: conversation} do
      {:ok, index_live, _html} = live(conn, ~p"/conversations")

      assert index_live
             |> element("#conversations-#{conversation.id} a", "Edit")
             |> render_click() =~
               "Edit Conversation"

      assert_patch(index_live, ~p"/conversations/#{conversation}/edit")

      assert index_live
             |> form("#conversation-form", conversation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#conversation-form", conversation: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/conversations")

      html = render(index_live)
      assert html =~ "Conversation updated successfully"
      assert html =~ "some updated subject"
    end

    test "deletes conversation in listing", %{conn: conn, conversation: conversation} do
      {:ok, index_live, _html} = live(conn, ~p"/conversations")

      assert index_live
             |> element("#conversations-#{conversation.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#conversations-#{conversation.id}")
    end
  end

  describe "Show" do
    setup [:create_conversation]

    test "displays conversation", %{conn: conn, conversation: conversation} do
      {:ok, _show_live, html} = live(conn, ~p"/conversations/#{conversation}")

      assert html =~ "Show Conversation"
      assert html =~ conversation.subject
    end

    test "updates conversation within modal", %{conn: conn, conversation: conversation} do
      {:ok, show_live, _html} = live(conn, ~p"/conversations/#{conversation}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Conversation"

      assert_patch(show_live, ~p"/conversations/#{conversation}/show/edit")

      assert show_live
             |> form("#conversation-form", conversation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#conversation-form", conversation: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/conversations/#{conversation}")

      html = render(show_live)
      assert html =~ "Conversation updated successfully"
      assert html =~ "some updated subject"
    end
  end
end
