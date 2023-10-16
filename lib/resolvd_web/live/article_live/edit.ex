defmodule ResolvdWeb.ArticleLive.Edit do
  use ResolvdWeb, :live_view

  alias Resolvd.Articles
  alias Resolvd.Articles.Article

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= if @article.id do %>
        <.back navigate={~p"/articles"}>Back to articles</.back>
      <% else %>
        <.back navigate={~p"/articles/#{@article}"}>Back to article</.back>
      <% end %>

      <.header>
        <%= @page_title %>
        <:subtitle>Use this form to manage article records in your database.</:subtitle>
      </.header>

      <.simple_form for={@form} id="article-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:category_id]} type="select" label="Category" options={@categories} />
        <.input field={@form[:subject]} type="text" label="Subject" />
        <.input type="hidden" field={@form[:body]} id="trix-editor" phx-hook="Trix" />
        <div id="richtext" phx-update="ignore">
          <trix-editor
            input="trix-editor"
            class="trix-content prose max-w-none prose-pre:text-black h-96 overflow-y-scroll"
            autofocus
          >
          </trix-editor>
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save Article</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    categories = Articles.list_categories_for_select(socket.assigns.current_user)
    {:ok, socket |> assign(:categories, categories)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    article = Articles.get_article!(id)

    socket
    |> assign(:page_title, "Edit Article")
    |> assign(:article, article)
    |> assign_form(Articles.change_article(article))
  end

  defp apply_action(socket, :new, _params) do
    article = %Article{}

    socket
    |> assign(:page_title, "New Article")
    |> assign(:article, article)
    |> assign_form(Articles.change_article(article))
  end

  # @impl true
  # def update(%{article: article} = assigns, socket) do
  #   changeset = Articles.change_article(article)
  #   categories = Articles.list_categories_for_select(assigns.current_user)

  #   {:ok,
  #    socket
  #    |> assign(assigns)
  #    |> assign(:categories, categories)
  #    |> assign_form(changeset)}
  # end

  @impl true
  def handle_event("validate", %{"article" => article_params}, socket) do
    changeset =
      socket.assigns.article
      |> Articles.change_article(article_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"article" => article_params}, socket) do
    action = if is_nil(socket.assigns.article.id), do: :new, else: :edit
    save_article(socket, action, article_params)
  end

  defp save_article(socket, :edit, article_params) do
    case Articles.update_article(
           socket.assigns.current_user,
           socket.assigns.article,
           article_params
         ) do
      {:ok, article} ->
        {:noreply,
         socket
         |> put_flash(:info, "Article updated successfully")
         |> push_navigate(to: ~p"/articles/#{article}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_article(socket, :new, article_params) do
    case Articles.create_article(socket.assigns.current_user, article_params) do
      {:ok, article} ->
        {:noreply,
         socket
         |> put_flash(:info, "Article created successfully")
         |> push_navigate(to: ~p"/articles/#{article}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
