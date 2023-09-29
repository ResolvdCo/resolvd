defmodule Resolvd.Mailboxes.Inbound.PairSupervisor do
  use Supervisor, restart: :transient

  alias Resolvd.Mailboxes.Inbound.Processor, as: InboundProcessor

  def start_link(_, args) do
    id = Keyword.get(args, :id)
    server = Keyword.get(args, :server)
    name = Keyword.get(args, :name)

    Supervisor.start_link(__MODULE__, %{id: id, server: server}, name: name)
  end

  def init(%{id: id, server: server}) do
    mailbox_atom = String.to_atom(id)

    children = [
      {Yugo.Client,
       name: mailbox_atom,
       server: server.server,
       username: server.username,
       password: server.password},
      {InboundProcessor, mailbox_atom: mailbox_atom}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
