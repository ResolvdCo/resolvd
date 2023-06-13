defmodule ResolvdWeb.MailServerLive.Index do
  use ResolvdWeb, :live_view

  alias Resolvd.Tenants
  alias Resolvd.Mailbox
  alias Resolvd.Mailbox.MailServer

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :mail_servers, Mailbox.list_mail_servers())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Mail server")
    |> assign(:mail_server, Mailbox.get_mail_server!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Mail server")
    |> assign(:mail_server, %MailServer{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Mail servers")
    |> assign(:mail_server, nil)
  end

  @impl true
  def handle_info({ResolvdWeb.MailServerLive.FormComponent, {:saved, mail_server}}, socket) do
    {:noreply, stream_insert(socket, :mail_servers, mail_server)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    mail_server = Mailbox.get_mail_server!(id)
    {:ok, _} = Mailbox.delete_mail_server(mail_server)

    {:noreply, stream_delete(socket, :mail_servers, mail_server)}
  end
end
