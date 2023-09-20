defmodule ResolvdWeb.MailboxLiveTest do
  use ResolvdWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resolvd.TenantsFixtures

  @create_attrs %{
    inbound_config: %{},
    inbound_type: "some inbound_type",
    outbound_config: %{},
    outbound_type: "some outbound_type"
  }
  @update_attrs %{
    inbound_config: %{},
    inbound_type: "some updated inbound_type",
    outbound_config: %{},
    outbound_type: "some updated outbound_type"
  }
  @invalid_attrs %{
    inbound_config: nil,
    inbound_type: nil,
    outbound_config: nil,
    outbound_type: nil
  }

  defp create_mailbox(_) do
    mailbox = mailbox_fixture()
    %{mailbox: mailbox}
  end

  describe "Index" do
    setup [:create_mailbox]

    test "lists all mailboxes", %{conn: conn, mailbox: mailbox} do
      {:ok, _index_live, html} = live(conn, ~p"/mailboxes")

      assert html =~ "Mailboxes"
      assert html =~ mailbox.inbound_type
    end

    test "saves new mailbox", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/mailboxes")

      assert index_live |> element("a", "New Mailbox") |> render_click() =~
               "New Mailbox"

      assert_patch(index_live, ~p"/mailboxes/new")

      assert index_live
             |> form("#mailbox-form", mailbox: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#mailbox-form", mailbox: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/mailboxes")

      html = render(index_live)
      assert html =~ "Mailbox created successfully"
      assert html =~ "some inbound_type"
    end

    test "updates mailbox in listing", %{conn: conn, mailbox: mailbox} do
      {:ok, index_live, _html} = live(conn, ~p"/mailboxes")

      assert index_live |> element("#mailboxes-#{mailbox.id} a", "Edit") |> render_click() =~
               "Edit Mailbox"

      assert_patch(index_live, ~p"/mailboxes/#{mailbox}/edit")

      assert index_live
             |> form("#mailbox-form", mailbox: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#mailbox-form", mailbox: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/mailboxes")

      html = render(index_live)
      assert html =~ "Mailbox updated successfully"
      assert html =~ "some updated inbound_type"
    end

    test "deletes mailbox in listing", %{conn: conn, mailbox: mailbox} do
      {:ok, index_live, _html} = live(conn, ~p"/mailboxes")

      assert index_live
             |> element("#mailboxes-#{mailbox.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#mailboxes-#{mailbox.id}")
    end
  end

  describe "Show" do
    setup [:create_mailbox]

    test "displays mailbox", %{conn: conn, mailbox: mailbox} do
      {:ok, _show_live, html} = live(conn, ~p"/mailboxes/#{mailbox}")

      assert html =~ "Show Mailbox"
      assert html =~ mailbox.inbound_type
    end

    test "updates mailbox within modal", %{conn: conn, mailbox: mailbox} do
      {:ok, show_live, _html} = live(conn, ~p"/mailboxes/#{mailbox}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Mailbox"

      assert_patch(show_live, ~p"/mailboxes/#{mailbox}/show/edit")

      assert show_live
             |> form("#mailbox-form", mailbox: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#mailbox-form", mailbox: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/mailboxes/#{mailbox}")

      html = render(show_live)
      assert html =~ "Mailbox updated successfully"
      assert html =~ "some updated inbound_type"
    end
  end
end
