defmodule ResolvdWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use ResolvdWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint ResolvdWeb.Endpoint

      use ResolvdWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import ResolvdWeb.ConnCase
    end
  end

  setup tags do
    Resolvd.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn}) do
    user = Resolvd.AccountsFixtures.user_fixture()
    %{conn: log_in_user(conn, user), user: user}
  end

  @doc """
  Setup helper that creates a new tenant & associated admin. It does not login the admin.

      setup :create_tenant_and_admin
  """
  def create_tenant_and_admin(attrs) do
    user = Resolvd.AccountsFixtures.user_fixture()
    {:ok, user} = Resolvd.Accounts.update_user_admin(user, true)
    tenant = Resolvd.Tenants.get_tenant_for_user!(user)

    attrs |> Map.put(:admin, user) |> Map.put(:tenant, tenant)
  end

  @doc """
  Logs in the admin that was created with create_tenant_and_admin

      setup [:create_tenant_and_admin, :log_in_admin]

  It stores an updated connection and a registered user in the
  test context.
  """
  def log_in_admin(%{conn: conn, admin: user}) do
    %{conn: log_in_user(conn, user), user: user}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_user(conn, user) do
    token = Resolvd.Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end
end
