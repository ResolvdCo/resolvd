defmodule Resolvd.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :slug, :string

      add :parent_id, references(:categories, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:categories, [:parent_id])

    create table(:articles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :subject, :string
      add :slug, :string
      add :body, :string

      add :category_id, references(:categories, on_delete: :nothing, type: :binary_id)
      add :user_id, references(:users, on_delete: :nilify_all, type: :binary_id)

      timestamps()
    end

    create index(:articles, [:category_id])
  end
end
