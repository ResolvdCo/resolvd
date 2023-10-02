defmodule Resolvd.CustomersTest do
  use Resolvd.DataCase

  alias Resolvd.Customers

  defp create_tenant(_) do
    tenant = Resolvd.AccountsFixtures.tenant_fixture()
    %{tenant: tenant}
  end

  describe "customers" do
    alias Resolvd.Customers.Customer
    setup [:create_tenant]

    import Resolvd.CustomersFixtures

    @invalid_attrs %{email: nil, name: nil, phone: nil}

    test "list_customers/0 returns all customers", %{tenant: tenant} do
      customer = customer_fixture(tenant)
      assert Customers.list_customers() == [customer]
    end

    test "get_customer!/1 returns the customer with given id", %{tenant: tenant} do
      customer = customer_fixture(tenant)
      assert Customers.get_customer!(customer.id) == customer
    end

    test "create_customer/1 with valid data creates a customer", %{tenant: tenant} do
      valid_attrs = %{email: "some email", name: "some name", phone: "some phone"}

      assert {:ok, %Customer{} = customer} = Customers.create_customer(valid_attrs)
      assert customer.email == "some email"
      assert customer.name == "some name"
      assert customer.phone == "some phone"
    end

    test "create_customer/1 with invalid data returns error changeset", %{tenant: tenant} do
      assert {:error, %Ecto.Changeset{}} = Customers.create_customer(@invalid_attrs)
    end

    test "update_customer/2 with valid data updates the customer", %{tenant: tenant} do
      customer = customer_fixture(tenant)

      update_attrs = %{
        email: "some updated email",
        name: "some updated name",
        phone: "some updated phone"
      }

      assert {:ok, %Customer{} = customer} = Customers.update_customer(customer, update_attrs)
      assert customer.email == "some updated email"
      assert customer.name == "some updated name"
      assert customer.phone == "some updated phone"
    end

    test "update_customer/2 with invalid data returns error changeset", %{tenant: tenant} do
      customer = customer_fixture(tenant)
      assert {:error, %Ecto.Changeset{}} = Customers.update_customer(customer, @invalid_attrs)
      assert customer == Customers.get_customer!(customer.id)
    end

    test "delete_customer/1 deletes the customer", %{tenant: tenant} do
      customer = customer_fixture(tenant)
      assert {:ok, %Customer{}} = Customers.delete_customer(customer)
      assert_raise Ecto.NoResultsError, fn -> Customers.get_customer!(customer.id) end
    end

    test "change_customer/1 returns a customer changeset", %{tenant: tenant} do
      customer = customer_fixture(tenant)
      assert %Ecto.Changeset{} = Customers.change_customer(customer)
    end
  end
end
