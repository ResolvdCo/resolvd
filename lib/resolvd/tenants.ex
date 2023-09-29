defmodule Resolvd.Tenants do
  import Ecto.Query, warn: false

  use ResolvdWeb, :verified_routes

  alias Resolvd.Repo

  alias Resolvd.Accounts.User
  alias Resolvd.Tenants.Tenant
  alias Resolvd.Mailboxes.Mailbox

  import Ecto.Changeset, only: [get_field: 2]

  def get_tenant!(id), do: Repo.get!(Tenant, id)

  def get_tenant_from_mailbox!(mailbox_id),
    do: Repo.one!(from(t in Tenant, left_join: m in Mailbox, on: m.id == ^mailbox_id))

  def get_tenant_for_user!(%User{tenant_id: tenant_id}), do: Repo.get_by!(Tenant, id: tenant_id)

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
      %{
        action: :confirmation_instructions,
        user_id: user.id,
        user_email: user.email,
        confirmed_at: user.confirmed_at
      }
      |> Resolvd.Workers.SendUserEmail.new()
      |> Oban.insert()

      {:ok, tenant, user}
    else
      err ->
        err
    end
  end

  def update_billing(%Tenant{} = tenant, attrs) do
    # raise "Permissions check"

    tenant
    |> Tenant.billing_changeset(attrs)
    |> Repo.update()
  end

  def change_billing(%Tenant{} = tenant, attrs \\ %{}) do
    Tenant.billing_changeset(tenant, attrs)
  end
end
