defmodule Resolvd.CustomersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resolvd.Customers` context.
  """

  @doc """
  Generate a customer.
  """
  def customer_fixture(tenant, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        email: "customer##{System.unique_integer()}@example.com",
        name: "Customer##{System.unique_integer()}",
        phone: "#{System.unique_integer()}"
      })

    {:ok, customer} = Resolvd.Customers.create_customer(tenant, attrs)

    customer
  end
end
