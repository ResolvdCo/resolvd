defmodule ResolvdWeb.ArticleLive.Index do
  use ResolvdWeb, :live_view

  alias Resolvd.Articles

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex grow justify-center p-10">
      <div class="flex flex-col w-auto min-w-[50%]">
        <.header>
          Articles
          <:actions>
            <.link navigate={~p"/articles/new"}>
              <.button>New Article</.button>
            </.link>
          </:actions>
        </.header>

        <.table
          id="articles"
          rows={@articles}
          row_click={fn article -> JS.navigate(~p"/articles/#{article}") end}
        >
          <:col :let={article} label="Category">
            <%= if article.category do %>
              <%= article.category.title %>
            <% end %>
          </:col>
          <:col :let={article} label="Subject"><%= article.subject %></:col>
          <:action :let={article}>
            <div class="sr-only">
              <.link navigate={~p"/articles/#{article}"}>Show</.link>
            </div>
          </:action>
        </.table>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Articles")
     |> assign(:articles, Articles.list_articles(socket.assigns.current_user))}
  end
end
