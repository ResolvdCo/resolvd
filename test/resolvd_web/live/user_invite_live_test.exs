defmodule ResolvdWeb.UserInviteLiveTest do
  use ResolvdWeb.ConnCase

  import Phoenix.LiveViewTest
  import Resolvd.AccountsFixtures

  alias Resolvd.Accounts

  describe "Invite user" do
    setup :create_tenant_and_admin

    test "allows user to set password and use account", %{
      conn: conn,
      tenant: tenant,
      admin: admin
    } do
      user =
        Resolvd.Accounts.invite_user(admin, %{
          name: "Fooey Bar",
          email: "foo@example.com"
        })

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_invite(user, tenant, url)
        end)

      {:ok, lv, _html} = live(conn, ~p"/users/invite/#{token}")

      form =
        form(lv, "#invite_form", %{
          "user" => %{
            "email" => "foo@example.com",
            "token" => token,
            "password" => "foobar123321",
            "password_confirmation" => "foobar123321"
          }
        })

      assert render_submit(form) =~ ~r/phx-trigger-action/

      conn = follow_trigger_action(form, conn)

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Welcome to Resolvd!"
    end
  end
end
