defmodule ResolvdWeb.Admin.CategoryLive.Index do
  use ResolvdWeb, :live_view

  alias Resolvd.Articles
  alias Resolvd.Articles.Category

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :categories, Articles.list_categories(socket.assigns.current_user))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Category")
    |> assign(:category, Articles.get_category!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Category")
    |> assign(:category, %Category{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Categories")
    |> assign(:category, nil)
  end

  @impl true
  def handle_info({ResolvdWeb.Admin.CategoryLive.FormComponent, {:saved, category}}, socket) do
    {:noreply, stream_insert(socket, :categories, category)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    category = Articles.get_category!(id)
    {:ok, _} = Articles.delete_category(category)

    {:noreply, stream_delete(socket, :categories, category)}
  end
end
