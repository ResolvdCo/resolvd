defmodule Resolvd.Articles.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "categories" do
    belongs_to :tenant, Resolvd.Tenants.Tenant

    field :title, :string
    field :slug, :string
    belongs_to :parent, Resolvd.Articles.Category

    timestamps()
  end

  import Ecto.Query, only: [from: 2]
  @behaviour Bodyguard.Schema

  def scope(query, %Resolvd.Accounts.User{tenant_id: tenant_id}, _) do
    from q in query, where: q.tenant_id == ^tenant_id
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> cast_slug()
  end

  def cast_slug(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{title: title}} ->
        put_change(changeset, :slug, Slug.slugify(title))

      _ ->
        changeset
    end
  end
end
