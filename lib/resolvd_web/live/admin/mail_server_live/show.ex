defmodule ResolvdWeb.Admin.MailServerLive.Show do
  use ResolvdWeb, :admin_live_view

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

  @impl true
  def handle_event("start", _, socket) do
    Mailbox.upstart_mail_server(socket.assigns.mail_server)

    {:noreply, socket}
  end

  def handle_event("stop", _, socket) do
    Mailbox.stop_mail_server(socket.assigns.mail_server)

    {:noreply, socket}
  end

  def handle_event("test_inbound", _, socket) do
    inbound = socket.assigns.mail_server.inbound_config

    email =
      Swoosh.Email.new()
      |> Swoosh.Email.to(inbound.username)
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
    outbound = socket.assigns.mail_server.outbound_config

    email =
      Swoosh.Email.new()
      |> Swoosh.Email.to({"Luke Strickland", "luke@axxim.net"})
      |> Swoosh.Email.from({outbound.username, outbound.username})
      |> Swoosh.Email.subject("Testing Email")
      |> Swoosh.Email.text_body("Hello world!")

    config = [
      adapter: Swoosh.Adapters.SMTP,
      relay: outbound.server,
      username: outbound.username,
      password: outbound.password,
      ssl: outbound.ssl,
      tls: outbound.tls,
      auth: outbound.auth,
      port: outbound.port
    ]

    with {:ok, metadata} <- Resolvd.Mailer.deliver(email, config) do
      {:noreply,
       socket |> put_flash(:info, "Sent an email from this inbox. #{inspect(metadata)}")}
    else
      err ->
        dbg(err)
        {:noreply, socket |> put_flash(:error, "There was an error sending to this inbox.")}
    end
  end

  defp page_title(:show), do: "Show Mail server"
  defp page_title(:edit), do: "Edit Mail server"
end
