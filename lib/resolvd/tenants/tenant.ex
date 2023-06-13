defmodule Resolvd.Tenants.Tenant do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tenants" do
    # Customer's name
    field :name, :string

    # Customer's domain for sample-customer.resolvd.app
    field :slug, :string

    # Custom domain to cname to sample-customer.resolvd.app
    field :domain, :string

    # Customer's email domain to be used for automatic signups
    # Avoiding this for now due to situations like gmail.com
    field :email_domain, :string

    timestamps()
  end

  @doc false
  def changeset(tenant, attrs) do
    tenant
    |> cast(attrs, [:name, :domain, :email_domain])
    |> validate_required([:name])
    |> cast_slug()
  end

  def cast_slug(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{name: name}} ->
        put_change(changeset, :slug, Slug.slugify(name))

      _ ->
        changeset
    end
  end
end
