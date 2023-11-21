defmodule ResolvdWeb.CustomerLive.Index do
  use ResolvdWeb, :live_view

  alias Resolvd.Customers
  alias Resolvd.Customers.Customer
  alias Resolvd.Conversations
  alias Resolvd.Accounts
  alias Resolvd.Mailboxes
  alias ResolvdWeb.Router.Helpers
  alias ResolvdWeb.Utils

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:customers, [])
     |> assign(:conversation, nil)
     |> assign(:query, "")
     |> assign(:users, Accounts.list_users(socket.assigns.current_user))
     |> assign(:mailboxes, Mailboxes.list_mailboxes(socket.assigns.current_user))}
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

  defp apply_action(socket, :index, %{"conversation_id" => conversation_id} = params) do
    conversation = Conversations.get_conversation!(socket.assigns.current_user, conversation_id)

    socket
    |> apply_action(:index, params |> Map.delete("conversation_id"))
    |> assign(:conversation, conversation)
    |> assign(:page_title, conversation.subject)
    |> stream(:messages, Conversations.list_messages_for_conversation(conversation), reset: true)
  end

  defp apply_action(socket, :index, %{"id" => id}) do
    case socket.assigns do
      %{customer: %Customer{id: ^id}} ->
        socket

      %{customer: %Customer{} = old_customer} ->
        customer = Customers.get_customer!(socket.assigns.current_user, id)
        switch_to_customer(socket, customer, old_customer)

      _ ->
        customers = Customers.list_customers(socket.assigns.current_user)
        customer = Customers.get_customer!(socket.assigns.current_user, id)

        socket
        |> stream(:customers, customers)
        |> switch_to_customer(customer, nil)
    end
  end

  defp apply_action(socket, :index, _params) do
    customers = Customers.list_customers(socket.assigns.current_user)

    socket
    |> stream(:customers, customers)
    |> redirect_to_first_customer(customers)
  end

  @impl true
  def handle_info({ResolvdWeb.CustomerLive.FormComponent, {:saved, customer}}, socket) do
    {:noreply, stream_insert(socket, :customers, customer)}
  end

  @impl true
  def handle_event("closed-modal", _, socket) do
    {:noreply, socket |> stream(:messages, [], reset: true) |> assign(:conversation, nil)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    customer = Customers.get_customer!(id)
    {:ok, _} = Customers.delete_customer(customer)

    {:noreply, stream_delete(socket, :customers, customer)}
  end

  @impl true
  def handle_event("priority_changed", %{"_target" => ["priority-" <> id]} = params, socket) do
    priority = Map.fetch!(params, "priority-#{id}")
    conversation = Conversations.get_conversation!(socket.assigns.current_user, id)
    conversation = Conversations.set_priority(conversation, priority == "true")

    {:noreply, stream_insert(socket, :conversations, conversation)}
  end

  @impl true
  def handle_event("status_changed", %{"_target" => ["resolved-" <> id]} = params, socket) do
    resolved = Map.fetch!(params, "resolved-#{id}")
    conversation = Conversations.get_conversation!(socket.assigns.current_user, id)
    conversation = Conversations.set_resolved(conversation, resolved == "true")

    {:noreply, stream_insert(socket, :conversations, conversation)}
  end

  @impl true
  def handle_event("mailbox_changed", %{"_target" => ["mailbox-" <> id]} = params, socket) do
    mailbox_id = Map.fetch!(params, "mailbox-#{id}")

    conversation = Conversations.get_conversation!(socket.assigns.current_user, id)
    mailbox = Mailboxes.get_mailbox!(socket.assigns.current_user, mailbox_id)
    conversation = Conversations.update_conversation_mailbox(conversation, mailbox)

    {:noreply, stream_insert(socket, :conversations, conversation)}
  end

  @impl true
  def handle_event("assignee_changed", %{"_target" => ["assignee-" <> id]} = params, socket) do
    user_id = Map.fetch!(params, "assignee-#{id}")

    conversation = Conversations.get_conversation!(socket.assigns.current_user, id)
    user = if user_id == "", do: nil, else: Accounts.get_user!(user_id)
    conversation = Conversations.update_conversation_user(conversation, user)

    {:noreply, stream_insert(socket, :conversations, conversation)}
  end

  @impl true
  def handle_event("search", %{"search" => query}, socket) do
    socket =
      case String.trim(query) do
        query when byte_size(query) >= 3 ->
          search_customers(query, socket)

        _ when byte_size(socket.assigns.query) >= 3 ->
          apply_action(socket, socket.assigns.live_action, %{})

        _ ->
          socket
      end

    {:noreply, assign(socket, :query, String.trim(query))}
  end

  @impl true
  def handle_event(event, data, socket) do
    dbg(event)
    dbg(data)
    {:noreply, socket}
  end

  defp switch_to_customer(socket, customer, nil) do
    socket
    |> apply_assigns(customer)
    |> push_event("highlight", %{id: "customers-#{customer.id}"})
  end

  defp switch_to_customer(socket, customer, old_customer) do
    socket
    |> apply_assigns(customer)
    |> push_event("highlight", %{id: "customers-#{customer.id}"})
    |> push_event("remove-highlight", %{id: "customers-#{old_customer.id}"})
  end

  defp redirect_to_first_customer(socket, [customer | _]) do
    socket
    |> push_patch(to: Helpers.customer_index_path(socket, :index, id: customer.id))
    |> apply_assigns(customer)
  end

  defp redirect_to_first_customer(socket, _customers) do
    socket
    |> assign(:customer, nil)
    |> assign(:page_title, "Customers")
  end

  defp apply_assigns(socket, customer) do
    socket
    |> assign(:customer, customer)
    |> assign(:page_title, Utils.display_name(customer))
    |> assign(:conversation, nil)
    |> stream(:conversations, Customers.get_conversations_for_customer(customer), reset: true)
  end

  defp search_customers(query, socket) do
    customers = Customers.search_customers(query)

    socket
    |> stream(:customers, customers, reset: true)
    |> redirect_to_first_customer(customers)
  end
end
