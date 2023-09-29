defmodule Resolvd.Mailboxes.Inbound.Processor do
  @moduledoc """
  MailProcessor is a simple GenServer that listens to the various mail
  connections, checking for new email, and ingesting them as messages.
  """
  use GenServer

  require Logger

  ## GenServer API

  def start_link(args) do
    mailbox_atom = Keyword.get(args, :mailbox_atom)

    GenServer.start_link(__MODULE__, mailbox_atom)
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

  ## GenServer Callbacks
  @impl true
  def init(mailbox_atom) do
    Logger.debug("[#{mailbox_atom}] Starting process")

    Yugo.subscribe(mailbox_atom)

    {:ok, %{mailbox_atom: mailbox_atom}}
  end

  @impl true
  def handle_info({:email, mailbox_atom, message}, state) do
    Logger.debug("[#{mailbox_atom}] Processing new email")
    mailbox = Resolvd.Mailboxes.get_mailbox!(Atom.to_string(mailbox_atom))
    parsed_email = Resolvd.Mailboxes.Mail.from_yugo_type(message)

    Resolvd.Mailboxes.process_customer_email(mailbox, parsed_email)

    {:noreply, state}
  end
end
