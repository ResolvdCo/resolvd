defmodule Resolvd.Tenants do
  import Ecto.Query, warn: false

  use ResolvdWeb, :verified_routes

  alias Resolvd.Repo

  alias Resolvd.Accounts
  alias Resolvd.Accounts.User
  alias Resolvd.Tenants.Tenant
  alias Resolvd.Mailbox.MailServer

  import Ecto.Changeset, only: [get_field: 2]

  def get_tenant!(id), do: Repo.get!(Tenant, id)

  def get_tenant_from_mailbox!(mailbox_id),
    do: Repo.one!(from(t in Tenant, left_join: m in MailServer, on: m.id == ^mailbox_id))

  @doc """
  Create a tenant and a user from a %TenantCreation{} changeset
  """
  def create_tenant(%Ecto.Changeset{} = tc) do
    with {:ok, tenant} <-
           Repo.insert(
             Tenant.changeset(%Tenant{}, %{
               name: get_field(tc, :company_name)
             })
           ),
         {:ok, user} <-
           Repo.insert(
             User.registration_changeset(
               %User{
                 tenant_id: tenant.id
               },
               %{
                 name: get_field(tc, :full_name),
                 email: get_field(tc, :email),
                 password: get_field(tc, :password),
                 is_admin: true
               }
             )
           ) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )

      {:ok, tenant, user}
    else
      err ->
        err
    end
  end
end
