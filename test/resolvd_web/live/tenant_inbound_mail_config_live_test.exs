defmodule ResolvdWeb.TenantInboundMailConfigLiveTest do
  use ResolvdWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resolvd.TenantsFixtures

  @create_attrs %{mailbox: "some mailbox", mark_when_read: true, password: "some password", port: 42, server: "some server", tls: true, type: "some type", username: "some username"}
  @update_attrs %{mailbox: "some updated mailbox", mark_when_read: false, password: "some updated password", port: 43, server: "some updated server", tls: false, type: "some updated type", username: "some updated username"}
  @invalid_attrs %{mailbox: nil, mark_when_read: false, password: nil, port: nil, server: nil, tls: false, type: nil, username: nil}

  defp create_tenant_inbound_mail_config(_) do
    tenant_inbound_mail_config = tenant_inbound_mail_config_fixture()
    %{tenant_inbound_mail_config: tenant_inbound_mail_config}
  end

  describe "Index" do
    setup [:create_tenant_inbound_mail_config]

    test "lists all tenant_inbound_mail_configs", %{conn: conn, tenant_inbound_mail_config: tenant_inbound_mail_config} do
      {:ok, _index_live, html} = live(conn, ~p"/tenant_inbound_mail_configs")

      assert html =~ "Listing Tenant inbound mail configs"
      assert html =~ tenant_inbound_mail_config.mailbox
    end

    test "saves new tenant_inbound_mail_config", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/tenant_inbound_mail_configs")

      assert index_live |> element("a", "New Tenant inbound mail config") |> render_click() =~
               "New Tenant inbound mail config"

      assert_patch(index_live, ~p"/tenant_inbound_mail_configs/new")

      assert index_live
             |> form("#tenant_inbound_mail_config-form", tenant_inbound_mail_config: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#tenant_inbound_mail_config-form", tenant_inbound_mail_config: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tenant_inbound_mail_configs")

      html = render(index_live)
      assert html =~ "Tenant inbound mail config created successfully"
      assert html =~ "some mailbox"
    end

    test "updates tenant_inbound_mail_config in listing", %{conn: conn, tenant_inbound_mail_config: tenant_inbound_mail_config} do
      {:ok, index_live, _html} = live(conn, ~p"/tenant_inbound_mail_configs")

      assert index_live |> element("#tenant_inbound_mail_configs-#{tenant_inbound_mail_config.id} a", "Edit") |> render_click() =~
               "Edit Tenant inbound mail config"

      assert_patch(index_live, ~p"/tenant_inbound_mail_configs/#{tenant_inbound_mail_config}/edit")

      assert index_live
             |> form("#tenant_inbound_mail_config-form", tenant_inbound_mail_config: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#tenant_inbound_mail_config-form", tenant_inbound_mail_config: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tenant_inbound_mail_configs")

      html = render(index_live)
      assert html =~ "Tenant inbound mail config updated successfully"
      assert html =~ "some updated mailbox"
    end

    test "deletes tenant_inbound_mail_config in listing", %{conn: conn, tenant_inbound_mail_config: tenant_inbound_mail_config} do
      {:ok, index_live, _html} = live(conn, ~p"/tenant_inbound_mail_configs")

      assert index_live |> element("#tenant_inbound_mail_configs-#{tenant_inbound_mail_config.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#tenant_inbound_mail_configs-#{tenant_inbound_mail_config.id}")
    end
  end

  describe "Show" do
    setup [:create_tenant_inbound_mail_config]

    test "displays tenant_inbound_mail_config", %{conn: conn, tenant_inbound_mail_config: tenant_inbound_mail_config} do
      {:ok, _show_live, html} = live(conn, ~p"/tenant_inbound_mail_configs/#{tenant_inbound_mail_config}")

      assert html =~ "Show Tenant inbound mail config"
      assert html =~ tenant_inbound_mail_config.mailbox
    end

    test "updates tenant_inbound_mail_config within modal", %{conn: conn, tenant_inbound_mail_config: tenant_inbound_mail_config} do
      {:ok, show_live, _html} = live(conn, ~p"/tenant_inbound_mail_configs/#{tenant_inbound_mail_config}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Tenant inbound mail config"

      assert_patch(show_live, ~p"/tenant_inbound_mail_configs/#{tenant_inbound_mail_config}/show/edit")

      assert show_live
             |> form("#tenant_inbound_mail_config-form", tenant_inbound_mail_config: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#tenant_inbound_mail_config-form", tenant_inbound_mail_config: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/tenant_inbound_mail_configs/#{tenant_inbound_mail_config}")

      html = render(show_live)
      assert html =~ "Tenant inbound mail config updated successfully"
      assert html =~ "some updated mailbox"
    end
  end
end
