defmodule Resolvd.Repo.Migrations.CreateMailboxes do
  use Ecto.Migration

  def change do
    create table(:mailboxes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :from, :string
      add :email_address, :string
      add :inbound_type, :string
      add :inbound_config, :map
      add :outbound_type, :string
      add :outbound_config, :map
      add :tenant_id, references(:tenants, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:mailboxes, [:tenant_id])
  end
end
