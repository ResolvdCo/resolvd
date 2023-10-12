defmodule Resolvd.Tenants do
  import Ecto.Query, warn: false

  use ResolvdWeb, :verified_routes

  alias Resolvd.Repo

  alias Resolvd.Accounts.User
  alias Resolvd.Tenants.Tenant
  alias Resolvd.Mailboxes.Mailbox

  import Ecto.Changeset, only: [get_field: 2]

  def get_tenant!(id), do: Repo.get!(Tenant, id)
  def get_tenant(id), do: Repo.get(Tenant, id)

  def get_tenant_from_mailbox!(mailbox_id),
    do: Repo.one!(from(t in Tenant, left_join: m in Mailbox, on: m.id == ^mailbox_id))

  def get_tenant_for_user!(%User{tenant_id: tenant_id}), do: Repo.get_by!(Tenant, id: tenant_id)

  @doc """
  Create a tenant and a user from a %TenantCreation{} changeset
  """
  def create_tenant(%Ecto.Changeset{} = tc) do
    tenant_params = %{
      name: get_field(tc, :company_name),
      users: [
        %{
          name: get_field(tc, :full_name),
          email: get_field(tc, :email),
          password: get_field(tc, :password),
          is_admin: true
        }
      ]
    }

    case %Tenant{} |> Tenant.changeset(tenant_params) |> Repo.insert() do
      {:ok, %Tenant{users: [user]}} ->
        {:ok, user}

      {:error, %Ecto.Changeset{changes: %{users: [user]}} = changeset} ->
        (changeset.errors ++ user.errors)
        |> Enum.reduce(tc, fn {err_key, {message, keys}}, ch ->
          Ecto.Changeset.add_error(ch, err_key, message, keys)
        end)
        |> Ecto.Changeset.apply_action(:insert)
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
