defmodule Resolvd.Articles.Article do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "articles" do
    belongs_to :tenant, Resolvd.Tenants.Tenant

    field :body, :string
    field :slug, :string
    field :subject, :string

    belongs_to :category, Resolvd.Articles.Category

    timestamps()
  end

  import Ecto.Query, only: [from: 2]
  @behaviour Bodyguard.Schema

  def scope(query, %Resolvd.Accounts.User{tenant_id: tenant_id}, _) do
    from q in query, where: q.tenant_id == ^tenant_id
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:subject, :body, :category_id])
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
