defmodule Resolvd.Articles.Article do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "articles" do
    field :body, :string
    field :slug, :string
    field :subject, :string
    belongs_to :category, Resolvd.Articles.Category

    timestamps()
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:subject, :body])
    |> validate_required([:subject, :body])
    |> cast_slug()
  end

  def cast_slug(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{subject: subject}} ->
        put_change(changeset, :slug, Slug.slugify(subject))

      _ ->
        changeset
    end
  end
end
