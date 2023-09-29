defmodule ResolvdWeb.CustomerLive.Index do
  use ResolvdWeb, :live_view

  alias Resolvd.Customers
  alias Resolvd.Customers.Customer

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :customers, Customers.list_customers(socket.assigns.current_user))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Customer")
    |> assign(:customer, Customers.get_customer!(socket.assigns.current_user, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Customer")
    |> assign(:customer, %Customer{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Customers")
    |> assign(:customer, nil)
  end

  @impl true
  def handle_info({ResolvdWeb.CustomerLive.FormComponent, {:saved, customer}}, socket) do
    {:noreply, stream_insert(socket, :customers, customer)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    customer = Customers.get_customer!(id)
    {:ok, _} = Customers.delete_customer(customer)

    {:noreply, stream_delete(socket, :customers, customer)}
  end
end
