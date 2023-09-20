defmodule ResolvdWeb.Admin.BillingLive do
  use ResolvdWeb, :admin_live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Billing Management
    </.header>
    """
  end
end
