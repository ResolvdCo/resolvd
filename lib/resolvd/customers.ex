defmodule Resolvd.Customers do
  @moduledoc """
  The Customers context.
  """

  import Ecto.Query, warn: false
  alias Resolvd.Repo

  alias Resolvd.Customers.Customer
  alias Resolvd.Tenants.Tenant
  alias Resolvd.Accounts.User
  alias Resolvd.Conversations.Conversation

  @doc """
  List all customers
  """
  def all_customers() do
    Customer |> Repo.all()
  end

  @doc """
  Returns the list of customers the user is allowed to see.

  ## Examples

      iex> list_customers(user)
      [%Customer{}, ...]

  """
  def list_customers(%User{} = user) do
    Customer
    |> Bodyguard.scope(user)
    |> Repo.all()
  end

  @doc """
  Gets a single customer.

  Raises `Ecto.NoResultsError` if the Customer does not exist.

  ## Examples

      iex> get_customer!(123)
      %Customer{}

      iex> get_customer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_customer!(id), do: Repo.get!(Customer, id)

  def get_customer!(%User{} = user, id) do
    Customer
    |> Bodyguard.scope(user)
    |> where(id: ^id)
    |> Repo.one!()
  end

  @doc """
  Gets all conversations for a customer.
  """
  def get_conversations_for_customer(%Customer{id: id}) do
    from(c in Conversation,
      where: [customer_id: ^id],
      order_by: [desc: c.updated_at],
      preload: [:customer]
    )
    |> Repo.all()
  end

  @doc """
  Creates a customer.

  ## Examples

      iex> create_customer(%{field: value})
      {:ok, %Customer{}}

      iex> create_customer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_customer(%Tenant{} = tenant, attrs \\ %{}) do
    %Customer{
      tenant: tenant
    }
    |> Customer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a customer.

  ## Examples

      iex> update_customer(customer, %{field: new_value})
      {:ok, %Customer{}}

      iex> update_customer(customer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_customer(%Customer{} = customer, attrs) do
    customer
    |> Customer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a customer.

  ## Examples

      iex> delete_customer(customer)
      {:ok, %Customer{}}

      iex> delete_customer(customer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_customer(%Customer{} = customer) do
    Repo.delete(customer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking customer changes.

  ## Examples

      iex> change_customer(customer)
      %Ecto.Changeset{data: %Customer{}}

  """
  def change_customer(%Customer{} = customer, attrs \\ %{}) do
    Customer.changeset(customer, attrs)
  end

  def get_or_create_customer_from_email(%Resolvd.Tenants.Tenant{} = tenant, email, name \\ nil) do
    query =
      from c in Customer,
        where: c.email == ^email

    case Repo.one(query) do
      %Customer{name: nil} = customer when not is_nil(name) ->
        {:ok, customer} = update_customer(customer, %{name: name})
        customer

      nil ->
        {:ok, customer} = create_customer(tenant, %{email: email, name: name})
        customer

      customer ->
        customer
    end
  end
end
