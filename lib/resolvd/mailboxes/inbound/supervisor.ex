defmodule Resolvd.Mailboxes.Inbound.Supervisor do
  use DynamicSupervisor

  alias Resolvd.Mailboxes.InboundProviders.IMAPProvider
  alias Resolvd.Mailboxes.Inbound.PairSupervisor

  @registry :inbound_pair_supervisors

  def start_link(init_args) do
    DynamicSupervisor.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def start_child(id, %IMAPProvider{} = server) do
    spec = {PairSupervisor, [id: id, server: server, name: via_tuple(id)]}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def stop_child(id) do
    case Registry.lookup(@registry, id) do
      [{pid, _}] ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)

      _ ->
        :ok
    end
  end

  def child_started?(id) do
    case Registry.lookup(@registry, id) do
      [{pid, _}] ->
        %{specs: specs, active: active} = Supervisor.count_children(pid)
        specs == active

      _ ->
        false
    end
  end

  @impl true
  def init(init_args) do
    # Loop through all mailboxes and init them
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [init_args]
    )
  end

  defp via_tuple(name), do: {:via, Registry, {@registry, name}}
end

# defmodule Resolvd.Mailboxes.InboundPairSupervisor do
#   use DynamicSupervisor

#   require Logger

#   alias Resolvd.Mailboxes.InboundProcessor

#   def start_link(_start_from, opts) do
#     Logger.info("InboundPairSupervisor.start_link")
#     # DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
#     start_child(opts)
#   end

#   def start_child(opts) do
#     server = Keyword.get(opts, :server)
#     Logger.info("InboundPairSupervisor.start_child")
#     # If MyWorker is not using the new child specs, we need to pass a map:
#     # spec = %{id: MyWorker, start: {MyWorker, :start_link, [foo, bar, baz]}}

#     # with {:ok, _first_child} <-
#     #        DynamicSupervisor.start_child(
#     #          __MODULE__,
#     #          {Yugo.Client,
#     #           server: server.server, username: server.username, password: server.password}
#     #        ),
#     #      {:ok, second_child} <-
#     #        DynamicSupervisor.start_child(__MODULE__, {InboundProcessor, server: server}) do
#     #   {:ok, second_child}
#     # end
#     # DynamicSupervisor.start_child(__MODULE__, {InboundProcessor, server: server})
#     DynamicSupervisor.start_child(
#       __MODULE__,
#       %{
#         id: Yugo.Client,
#         start:
#           {Yugo.Client, :start_link,
#            [server: server.server, username: server.username, password: server.password]}
#       }
#     )

#   end

#   @impl true
#   def init(init_args) do
#     Logger.info("InboundPairSupervisor.init")
#     dbg(init_args)

#     DynamicSupervisor.init(
#       strategy: :one_for_one,
#       max_children: 2,
#       extra_arguments: [init_args]
#     )
#   end
# end

# defmodule Resolvd.Mailboxes.YugoStarter do
#   use GenServer

#   def start_link(_start_from, opts) do
#     GenServer.start(Yugo.Client, opts)
#   end

#   def init(init_arg) do
#     {:ok, init_arg}
#   end
# end
