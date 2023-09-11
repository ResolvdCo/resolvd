defmodule Resolvd.Mailbox.InboundProcessor do
  @moduledoc """
  MailProcessor is a simple GenServer that listens to the various mail
  connections, checking for new email, and ingesting them as messages.
  """
  use GenServer

  @registry :inbound_processors

  require Logger

  ## GenServer API

  def start_link(_start_from, opts \\ []) do
    Logger.info("InboundProcessor.start_link")
    id = Keyword.get(opts, :id)
    server = Keyword.get(opts, :server)

    GenServer.start_link(__MODULE__, %{id: id, server: server}, name: via_tuple(id))
  end

  @doc """
  This function will be called by the supervisor to retrieve the specification
  of the child process.The child process is configured to restart only if it
  terminates abnormally.
  """
  def child_spec(process_name) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [process_name]},
      restart: :transient
    }
  end

  def stop(process_name, stop_reason) do
    Logger.info("InboundProcessor stopping for #{process_name}")
    Registry.lookup(@registry, process_name) |> dbg()
    process_name |> via_tuple() |> GenServer.stop(stop_reason)
  end

  def alive?(process_name) do
    !is_nil(process_name |> via_tuple() |> GenServer.whereis())
  end

  ## GenServer Callbacks
  @impl true
  def init(%{id: id, server: server}) do
    Logger.info("InboundProcessor starting for #{id}")
    mailbox_atom = String.to_atom(id)

    {:ok, yugo_pid} =
      Yugo.Client.start_link(
        name: mailbox_atom,
        server: server.server,
        username: server.username,
        password: server.password
      )

    Yugo.subscribe(mailbox_atom)

    {:ok, %{mailbox_atom: mailbox_atom, yugo_pid: yugo_pid}}
  end

  @impl true
  def terminate(reason, state) do
    # Logger.info("InboundProcessor terminating for #{reason}")

    # Is this normal?
    Yugo.unsubscribe(state.mailbox_atom)
    GenServer.stop(state.yugo_pid, :normal)

    {:shutdown, reason}
  end

  @impl true
  def handle_info({:email, mailbox_atom, message}, state) do
    Logger.info("Got new email")
    dbg(message)
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

  ## Private Functions
  defp via_tuple(name),
    do: {:via, Registry, {@registry, name}}
end
