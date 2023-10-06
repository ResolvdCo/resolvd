defmodule ResolvdWeb.DashboardLive.Index do
  use ResolvdWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:page_title, "Dashboard")}
  end

  @impl true
  def render(assigns) do
    ~H"<.header>Dashboard</.header>"
  end
end
