defmodule ResolvdWeb.MailServerLiveTest do
  use ResolvdWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resolvd.TenantsFixtures

  @create_attrs %{inbound_config: %{}, inbound_type: "some inbound_type", outbound_config: %{}, outbound_type: "some outbound_type"}
  @update_attrs %{inbound_config: %{}, inbound_type: "some updated inbound_type", outbound_config: %{}, outbound_type: "some updated outbound_type"}
  @invalid_attrs %{inbound_config: nil, inbound_type: nil, outbound_config: nil, outbound_type: nil}

  defp create_mail_server(_) do
    mail_server = mail_server_fixture()
    %{mail_server: mail_server}
  end

  describe "Index" do
    setup [:create_mail_server]

    test "lists all mail_servers", %{conn: conn, mail_server: mail_server} do
      {:ok, _index_live, html} = live(conn, ~p"/mail_servers")

      assert html =~ "Listing Mail servers"
      assert html =~ mail_server.inbound_type
    end

    test "saves new mail_server", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/mail_servers")

      assert index_live |> element("a", "New Mail server") |> render_click() =~
               "New Mail server"

      assert_patch(index_live, ~p"/mail_servers/new")

      assert index_live
             |> form("#mail_server-form", mail_server: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#mail_server-form", mail_server: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/mail_servers")

      html = render(index_live)
      assert html =~ "Mail server created successfully"
      assert html =~ "some inbound_type"
    end

    test "updates mail_server in listing", %{conn: conn, mail_server: mail_server} do
      {:ok, index_live, _html} = live(conn, ~p"/mail_servers")

      assert index_live |> element("#mail_servers-#{mail_server.id} a", "Edit") |> render_click() =~
               "Edit Mail server"

      assert_patch(index_live, ~p"/mail_servers/#{mail_server}/edit")

      assert index_live
             |> form("#mail_server-form", mail_server: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#mail_server-form", mail_server: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/mail_servers")

      html = render(index_live)
      assert html =~ "Mail server updated successfully"
      assert html =~ "some updated inbound_type"
    end

    test "deletes mail_server in listing", %{conn: conn, mail_server: mail_server} do
      {:ok, index_live, _html} = live(conn, ~p"/mail_servers")

      assert index_live |> element("#mail_servers-#{mail_server.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#mail_servers-#{mail_server.id}")
    end
  end

  describe "Show" do
    setup [:create_mail_server]

    test "displays mail_server", %{conn: conn, mail_server: mail_server} do
      {:ok, _show_live, html} = live(conn, ~p"/mail_servers/#{mail_server}")

      assert html =~ "Show Mail server"
      assert html =~ mail_server.inbound_type
    end

    test "updates mail_server within modal", %{conn: conn, mail_server: mail_server} do
      {:ok, show_live, _html} = live(conn, ~p"/mail_servers/#{mail_server}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Mail server"

      assert_patch(show_live, ~p"/mail_servers/#{mail_server}/show/edit")

      assert show_live
             |> form("#mail_server-form", mail_server: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#mail_server-form", mail_server: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/mail_servers/#{mail_server}")

      html = render(show_live)
      assert html =~ "Mail server updated successfully"
      assert html =~ "some updated inbound_type"
    end
  end
end
