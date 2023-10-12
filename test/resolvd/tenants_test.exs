defmodule Resolvd.TenantsTest do
  use Resolvd.DataCase

  alias Resolvd.Tenants
  alias Resolvd.Tenants.TenantCreation

  describe "Tenant Actions" do
    test "create_tenant/1 creates a tenant and user" do
      changeset =
        TenantCreation.changeset(%TenantCreation{}, %{
          company_name: "Test Company",
          full_name: "Full Name",
          email: "luke@example.com",
          password: "foobar123Iam12chars!"
        })

      assert {:ok, user} = Tenants.create_tenant(changeset)
      assert user.email == "luke@example.com"

      tenant = Tenants.get_tenant_for_user!(user)
      assert tenant.name == "Test Company"
      assert tenant.slug == "test-company"
    end
  end
end
