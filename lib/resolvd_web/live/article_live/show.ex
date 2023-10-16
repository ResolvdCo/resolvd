defmodule ResolvdWeb.ArticleLive.Show do
  use ResolvdWeb, :live_view

  alias Resolvd.Articles

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Article <%= @article.id %>
      <:subtitle>This is a article record from your database.</:subtitle>
      <:actions>
        <.link navigate={~p"/articles/#{@article}/edit"} phx-click={JS.push_focus()}>
          <.button>Edit article</.button>
        </.link>
        <.link phx-click={JS.push("delete", value: %{id: @article.id})} data-confirm="Are you sure?">
          <.button>Delete article</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Subject"><%= @article.subject %></:item>
      <:item title="Slug"><%= @article.slug %></:item>
    </.list>

    <br />

    <h2><%= @article.subject %></h2>
    <article class="prose max-w-none">
      <%= raw(@article.body) %>
    </article>

    <.back navigate={~p"/articles"}>Back to articles</.back>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    article = Articles.get_article!(id)

    {:noreply,
     socket
     |> assign(:page_title, article.subject)
     |> assign(:article, article)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    article = Articles.get_article!(id)
    {:ok, _} = Articles.delete_article(article)

    {:noreply,
     socket
     |> push_navigate(to: ~p"/articles")
     |> put_flash(:info, "Successfully deleted article.")}
  end
end
