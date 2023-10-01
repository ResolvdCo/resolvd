defmodule ResolvdWeb.Admin.UserLive.Index do
  use ResolvdWeb, :admin_live_view

  alias Resolvd.Accounts
  alias Resolvd.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :users, Accounts.list_users(socket.assigns.current_user))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Invite User")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Users")
    |> assign(:user, nil)
  end

  @impl true
  def handle_info({ResolvdWeb.Admin.UserLive.FormComponent, {:saved, user}}, socket) do
    {:noreply, stream_insert(socket, :users, user)}
  end

  @impl true
  def handle_event("delete", %{"id" => _id}, socket) do
    # category = Accounts.get_user!(id)
    # {:ok, _} = Articles.delete_category(category)

    # {:noreply, stream_delete(socket, :categories, category)}
    {:noreply, socket}
  end

  def handle_event("resend_invite", %{"id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    tenant = Resolvd.Tenants.get_tenant!(user.tenant_id)

    Accounts.deliver_user_invite(user, tenant, &url(~p"/users/confirm/#{&1}"))

    {:noreply, socket |> put_flash(:info, "User invitation sent.")}
  end
end
