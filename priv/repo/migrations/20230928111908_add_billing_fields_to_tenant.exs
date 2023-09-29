defmodule Resolvd.Repo.Migrations.AddBillingFieldsToTenant do
  use Ecto.Migration

  def change do
    alter table(:tenants) do
      add :plan_status, :string, nullable: true
      add :plan_renewal, :utc_datetime
      add :plan_expires, :utc_datetime, nullable: true
      add :stripe_subscription_id, :string
      add :stripe_customer_id, :string
    end
  end
end
