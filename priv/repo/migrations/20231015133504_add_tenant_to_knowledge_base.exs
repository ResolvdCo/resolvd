defmodule Resolvd.Repo.Migrations.AddTenantToKnowledgeBase do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      add :tenant_id, references(:tenants, type: :binary_id, on_delete: :delete_all), null: false
    end

    alter table(:articles) do
      add :tenant_id, references(:tenants, type: :binary_id, on_delete: :delete_all), null: false

      modify :body, :text
    end
  end
end
