defmodule Resolvd.Tenants do
  import Ecto.Query, warn: false

  use ResolvdWeb, :verified_routes

  alias Resolvd.Mailbox
  alias Resolvd.Repo
  alias Ecto.Multi

  alias Resolvd.Accounts
  alias Resolvd.Accounts.User
  alias Resolvd.Tenants.Tenant
  alias Resolvd.Tenants.TenantCreation
  alias Resolvd.Mailbox.MailServer

  import Ecto.Changeset, only: [get_field: 2]

  def get_tenant!(id), do: Repo.get!(Tenant, id)

  def get_tenant_from_mailbox!(mailbox_id),
    do: Repo.one!(from t in Tenant, left_join: m in MailServer, on: m.id == ^mailbox_id)

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
                 password: get_field(tc, :password)
               }
             )
           ) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )

      {:ok, user}
    else
      err ->
        dbg(err)
    end
  end
end
