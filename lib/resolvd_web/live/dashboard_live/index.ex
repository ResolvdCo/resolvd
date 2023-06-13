defmodule ResolvdWeb.DashboardLive.Index do
  use ResolvdWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"<h2>Dashboard</h2>"
  end
end
