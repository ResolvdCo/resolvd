defmodule Resolvd.Repo.Migrations.AddStatusFieldsToConversation do
  use Ecto.Migration

  def change do
    alter table(:conversations) do
      add :is_resolved, :boolean
      add :is_prioritized, :boolean
    end
  end
end
