defmodule Resolvd.Repo.Migrations.CreateMailServers do
  use Ecto.Migration

  def change do
    create table(:mail_servers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :inbound_type, :string
      add :inbound_config, :map
      add :outbound_type, :string
      add :outbound_config, :map
      add :tenant_id, references(:tenants, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:mail_servers, [:tenant_id])
  end
end
