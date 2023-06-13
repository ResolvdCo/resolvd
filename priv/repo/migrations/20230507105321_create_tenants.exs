defmodule Resolvd.Repo.Migrations.CreateTenants do
  use Ecto.Migration

  def change do
    create table(:tenants, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string, null: false
      add :slug, :string, null: false
      add :domain, :string
      add :email_domain, :string

      timestamps()
    end

    create unique_index(:tenants, [:slug])
    create unique_index(:tenants, [:domain])
    create unique_index(:tenants, [:email_domain])
  end
end
