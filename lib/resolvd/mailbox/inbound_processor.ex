defmodule Resolvd.Mailbox.InboundProcessor do
  @moduledoc """
  MailProcessor is a simple GenServer that listens to the various mail
  connections, checking for new email, and ingesting them as messages.
  """
  use GenServer

  require Logger

  def start_link(_start_from, opts \\ []) do
    Logger.info("InboundProcessor.start_link")
    id = Keyword.get(opts, :id)
    server = Keyword.get(opts, :server)

    GenServer.start_link(__MODULE__, %{id: id, server: server}, name: :"imap_processor:#{id}")
  end

  def init(%{id: id, server: server}) do
    Logger.info("InboundProcessor started for #{id}")
    mailbox_atom = String.to_atom(id)

    {:ok, yugo_pid} =
      Yugo.Client.start_link(
        name: mailbox_atom,
        server: server.server,
        username: server.username,
        password: server.password
      )

    Yugo.subscribe(mailbox_atom)

    {:ok, %{yugo_pid: yugo_pid}}
  end

  def handle_info({:email, mailbox_atom, message}, state) do
    tenant = Resolvd.Tenants.get_tenant_from_mailbox!(Atom.to_string(mailbox_atom))

    mail =
      message
      |> Resolvd.Mailbox.Mail.from_yugo_type()

    Resolvd.Conversations.create_or_update_conversation_from_email(tenant, mail)
    |> dbg()

    # email =
    #   Swoosh.Email.new()
    #   |> Swoosh.Email.to(message.reply_to)
    #   |> Swoosh.Email.from({"Resolvd", "resolvd@axxim.net"})
    #   |> Swoosh.Email.subject(message.subject)
    #   |> Swoosh.Email.text_body("We got your ticket bruv! Will respond soon.")
    #   |> Swoosh.Email.header("In-Reply-To", message.message_id)
    #   |> Swoosh.Email.header("References", message.message_id)

    # Resolvd.Mailer.deliver(email) |> dbg()

    {:noreply, state}
  end
end
