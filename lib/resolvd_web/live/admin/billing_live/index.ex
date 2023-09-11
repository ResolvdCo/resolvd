defmodule ResolvdWeb.Admin.BillingLive do
  use ResolvdWeb, :admin_live_view

  alias Resolvd.Mailbox
  alias Resolvd.Mailbox.MailServer

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :mail_servers, Mailbox.list_mail_servers())}
  end

  def render(assigns) do
    ~H"""
    <.header>
      Billing Management
    </.header>
    """
  end
end
