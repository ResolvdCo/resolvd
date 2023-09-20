defmodule Resolvd.Mailboxes.InboundProcessor do
  @moduledoc """
  MailProcessor is a simple GenServer that listens to the various mail
  connections, checking for new email, and ingesting them as messages.
  """
  use GenServer

  @registry :inbound_processors

  require Logger

  ## GenServer API

  def start_link(_start_from, opts \\ []) do
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
    Registry.lookup(@registry, process_name) |> dbg()
    process_name |> via_tuple() |> GenServer.stop(stop_reason)
  end

  def alive?(process_name) do
    !is_nil(process_name |> via_tuple() |> GenServer.whereis())
  end

  ## GenServer Callbacks
  @impl true
  def init(%{id: id, server: server}) do
    Logger.debug("[#{id}] Starting process")
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
    Logger.debug("[#{state.mailbox_atom}] Terminating process")

    # Is this normal?
    Yugo.unsubscribe(state.mailbox_atom)
    GenServer.stop(state.yugo_pid, :normal)

    {:shutdown, reason}
  end

  @impl true
  def handle_info({:email, mailbox_atom, message}, state) do
    Logger.debug("[#{mailbox_atom}] Processing new email")
    mailbox = Resolvd.Mailboxes.get_mailbox!(Atom.to_string(mailbox_atom))
    parsed_email = Resolvd.Mailboxes.Mail.from_yugo_type(message)

    Resolvd.Mailboxes.process_customer_email(mailbox, parsed_email)

    {:noreply, state}
  end

  ## Private Functions
  defp via_tuple(name),
    do: {:via, Registry, {@registry, name}}
end
