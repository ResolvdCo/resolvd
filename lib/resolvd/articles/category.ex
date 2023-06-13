defmodule Resolvd.Articles.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "categories" do
    field :slug, :string
    field :title, :string
    field :parent_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:title, :slug])
    |> validate_required([:title, :slug])
  end
end
