defmodule Resolvd.Repo.Migrations.AddCustomerUniqueIndex do
  use Ecto.Migration

  def change do
    create index("customers", [:tenant_id, :email], unique: true)
  end
end
