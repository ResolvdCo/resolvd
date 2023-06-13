defmodule ResolvdWeb.MailServerLive.Show do
  use ResolvdWeb, :live_view

  alias Resolvd.Mailbox

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:mail_server, Mailbox.get_mail_server!(id))}
  end

  defp page_title(:show), do: "Show Mail server"
  defp page_title(:edit), do: "Edit Mail server"
end
