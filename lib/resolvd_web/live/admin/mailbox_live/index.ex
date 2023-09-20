defmodule ResolvdWeb.Admin.MailboxLive.Index do
  use ResolvdWeb, :admin_live_view

  alias Resolvd.Mailboxes
  alias Resolvd.Mailboxes.Mailbox

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :mailboxes, Mailboxes.list_mailboxes(socket.assigns.current_user))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Mailbox")
    |> assign(:mailbox, Mailboxes.get_mailbox!(socket.assigns.current_user, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Mailbox")
    |> assign(:mailbox, %Mailbox{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Mailbox")
    |> assign(:mailbox, nil)
  end

  @impl true
  def handle_info({ResolvdWeb.Admin.MailboxLive.FormComponent, {:saved, mailbox}}, socket) do
    {:noreply, stream_insert(socket, :mailboxes, mailbox)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    mailbox = Mailboxes.get_mailbox!(socket.assigns.current_user, id)
    {:ok, _} = Mailboxes.delete_mailbox(socket.assigns.current_user, mailbox)

    {:noreply, stream_delete(socket, :mailboxes, mailbox)}
  end
end
