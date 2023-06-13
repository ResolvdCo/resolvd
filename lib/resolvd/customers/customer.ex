defmodule Resolvd.Customers.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "customers" do
    field :email, :string
    field :name, :string
    field :phone, :string

    belongs_to :tenant, Resolvd.Tenants.Tenant

    timestamps()
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:name, :email, :phone])
    |> validate_required([:name, :email])
    |> cast_assoc(:tenant)
  end
end
