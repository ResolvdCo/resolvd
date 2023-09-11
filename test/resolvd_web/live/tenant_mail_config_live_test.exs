defmodule ResolvdWeb.TenantMailConfigLiveTest do
  use ResolvdWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resolvd.TenantsFixtures

  @create_attrs %{adapter: "some adapter", config: %{}, direction: "some direction"}
  @update_attrs %{
    adapter: "some updated adapter",
    config: %{},
    direction: "some updated direction"
  }
  @invalid_attrs %{adapter: nil, config: nil, direction: nil}

  defp create_tenant_mail_config(_) do
    tenant_mail_config = tenant_mail_config_fixture()
    %{tenant_mail_config: tenant_mail_config}
  end

  describe "Index" do
    setup [:create_tenant_mail_config]

    test "lists all tenant_mail_configs", %{conn: conn, tenant_mail_config: tenant_mail_config} do
      {:ok, _index_live, html} = live(conn, ~p"/tenant_mail_configs")

      assert html =~ "Tenant mail configs"
      assert html =~ tenant_mail_config.adapter
    end

    test "saves new tenant_mail_config", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/tenant_mail_configs")

      assert index_live |> element("a", "New Tenant mail config") |> render_click() =~
               "New Tenant mail config"

      assert_patch(index_live, ~p"/tenant_mail_configs/new")

      assert index_live
             |> form("#tenant_mail_config-form", tenant_mail_config: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#tenant_mail_config-form", tenant_mail_config: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tenant_mail_configs")

      html = render(index_live)
      assert html =~ "Tenant mail config created successfully"
      assert html =~ "some adapter"
    end

    test "updates tenant_mail_config in listing", %{
      conn: conn,
      tenant_mail_config: tenant_mail_config
    } do
      {:ok, index_live, _html} = live(conn, ~p"/tenant_mail_configs")

      assert index_live
             |> element("#tenant_mail_configs-#{tenant_mail_config.id} a", "Edit")
             |> render_click() =~
               "Edit Tenant mail config"

      assert_patch(index_live, ~p"/tenant_mail_configs/#{tenant_mail_config}/edit")

      assert index_live
             |> form("#tenant_mail_config-form", tenant_mail_config: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#tenant_mail_config-form", tenant_mail_config: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tenant_mail_configs")

      html = render(index_live)
      assert html =~ "Tenant mail config updated successfully"
      assert html =~ "some updated adapter"
    end

    test "deletes tenant_mail_config in listing", %{
      conn: conn,
      tenant_mail_config: tenant_mail_config
    } do
      {:ok, index_live, _html} = live(conn, ~p"/tenant_mail_configs")

      assert index_live
             |> element("#tenant_mail_configs-#{tenant_mail_config.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#tenant_mail_configs-#{tenant_mail_config.id}")
    end
  end

  describe "Show" do
    setup [:create_tenant_mail_config]

    test "displays tenant_mail_config", %{conn: conn, tenant_mail_config: tenant_mail_config} do
      {:ok, _show_live, html} = live(conn, ~p"/tenant_mail_configs/#{tenant_mail_config}")

      assert html =~ "Show Tenant mail config"
      assert html =~ tenant_mail_config.adapter
    end

    test "updates tenant_mail_config within modal", %{
      conn: conn,
      tenant_mail_config: tenant_mail_config
    } do
      {:ok, show_live, _html} = live(conn, ~p"/tenant_mail_configs/#{tenant_mail_config}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Tenant mail config"

      assert_patch(show_live, ~p"/tenant_mail_configs/#{tenant_mail_config}/show/edit")

      assert show_live
             |> form("#tenant_mail_config-form", tenant_mail_config: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#tenant_mail_config-form", tenant_mail_config: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/tenant_mail_configs/#{tenant_mail_config}")

      html = render(show_live)
      assert html =~ "Tenant mail config updated successfully"
      assert html =~ "some updated adapter"
    end
  end
end
