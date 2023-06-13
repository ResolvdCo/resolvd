defmodule Resolvd.Articles.Article do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "articles" do
    field :body, :string
    field :slug, :string
    field :subject, :string
    field :category_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:subject, :slug, :body])
    |> validate_required([:subject, :slug, :body])
  end
end
