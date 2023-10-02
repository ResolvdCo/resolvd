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
        email: "some email",
        name: "some name",
        phone: "some phone"
      })

    {:ok, customer} = Resolvd.Customers.create_customer(tenant, attrs)

    customer
  end
end
