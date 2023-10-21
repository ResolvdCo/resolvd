defmodule Resolvd.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resolvd.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"
  def unique_user_name, do: "Dave ##{System.unique_integer()} Example"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def valid_tenant_creation_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      company_name: "ExampleCompany#{System.unique_integer()}",
      full_name: "Dave ##{System.unique_integer()} Example"
    })
  end

  def user_fixture(attrs \\ %{})

  def user_fixture(%Resolvd.Accounts.User{tenant_id: tenant_id}) do
    params = valid_user_attributes(%{name: unique_user_name()})

    {:ok, user} =
      %Resolvd.Accounts.User{tenant_id: tenant_id}
      |> Resolvd.Accounts.User.invite_changeset(params)
      |> Resolvd.Repo.insert!()
      |> Resolvd.Accounts.accept_invite(%{password: valid_user_password()})

    user
  end

  def user_fixture(attrs) do
    # For now this creates a tenant each time too
    # Should be refactored though for better testing

    attrs = valid_tenant_creation_attributes(attrs)

    {:ok, user} =
      Resolvd.Tenants.create_tenant(
        Resolvd.Tenants.TenantCreation.changeset(%Resolvd.Tenants.TenantCreation{}, attrs)
      )

    user
  end

  def tenant_fixture(attrs \\ %{}) do
    # For now this creates a tenant each time too
    # Should be refactored though for better testing

    attrs = valid_tenant_creation_attributes(attrs)

    {:ok, user} =
      Resolvd.Tenants.create_tenant(
        Resolvd.Tenants.TenantCreation.changeset(%Resolvd.Tenants.TenantCreation{}, attrs)
      )

    Resolvd.Tenants.get_tenant_for_user!(user)
  end

  def extract_user_token(fun) do
    {:ok, %Oban.Job{args: %{"url" => token}}} = fun.(&"#{&1}")
    token
  end
end
