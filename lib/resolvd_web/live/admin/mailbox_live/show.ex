defmodule ResolvdWeb.Admin.MailboxLive.Show do
  alias Phoenix.PubSub
  use ResolvdWeb, :admin_live_view

  alias Resolvd.Mailboxes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    mailbox = Mailboxes.get_mailbox!(socket.assigns.current_user, id)
    PubSub.subscribe(Resolvd.PubSub, id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:mailbox, mailbox)
     |> assign(:mailbox_running, Mailboxes.mailbox_running?(mailbox))}
  end

  @impl true
  def handle_event("start", _, socket) do
    Mailboxes.upstart_mailbox(socket.assigns.mailbox)

    {:noreply, socket}
  end

  def handle_event("stop", _, socket) do
    Mailboxes.stop_mailbox(socket.assigns.mailbox)

    {:noreply, socket}
  end

  def handle_event("test_inbound", _, socket) do
    email =
      Swoosh.Email.new()
      |> Swoosh.Email.to(socket.assigns.mailbox.email_address)
      |> Swoosh.Email.from({"Resolvd", "test@resolvd.co"})
      |> Swoosh.Email.subject("Testing Email")
      |> Swoosh.Email.text_body("Hello world!")

    with {:ok, _metadata} <- Resolvd.Mailer.deliver(email) do
      {:noreply, socket |> put_flash(:info, "Sent an email to this inbox.")}
    else
      _ ->
        {:noreply, socket |> put_flash(:error, "There was an error sending to this inbox.")}
    end
  end

  def handle_event("test_outbound", _, socket) do
    mailbox = socket.assigns.mailbox
    current_user = socket.assigns.current_user

    email =
      Swoosh.Email.new()
      |> Swoosh.Email.to({current_user.name, current_user.email})
      |> Swoosh.Email.subject("Testing Email")
      |> Swoosh.Email.html_body("Hello world, this is a test!")
      |> Swoosh.Email.text_body("Hello world, this is a test!")

    with {:ok, _metadata} <- Resolvd.Mailboxes.send_customer_email(mailbox, email) do
      {:noreply,
       socket |> put_flash(:info, "Sent an email from this mailbox to #{current_user.email}.")}
    else
      err ->
        dbg(err)
        {:noreply, socket |> put_flash(:error, "There was an error sending to this inbox.")}
    end
  end

  @impl true
  def handle_info({:update_status, mailbox_running}, socket) do
    {:noreply, assign(socket, :mailbox_running, mailbox_running)}
  end

  defp page_title(:show), do: "Show Mailbox"
  defp page_title(:edit), do: "Edit Mailbox"
end
