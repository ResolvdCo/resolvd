defmodule ResolvdWeb.Admin.BillingLive do
  use ResolvdWeb, :admin_live_view

  alias Resolvd.Mailbox
  alias Resolvd.Mailboxes.Mailbox

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.header>
      Billing Management
    </.header>
    """
  end
end
