defmodule Resolvd.Mailbox.InboundSupervisor do
  use DynamicSupervisor

  alias Resolvd.Mailbox.InboundProviders.IMAPProvider
  alias Resolvd.Mailbox.InboundProcessor

  def start_link(init_args) do
    DynamicSupervisor.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def start_child(id, %IMAPProvider{} = server) do
    # If MyWorker is not using the new child specs, we need to pass a map:
    # spec = %{id: MyWorker, start: {MyWorker, :start_link, [foo, bar, baz]}}
    # spec = {InboundPairSupervisor, server: server}
    spec = {InboundProcessor, id: id, server: server}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(init_args) do
    # Loop through all mailboxes and init them
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [init_args]
    )
  end
end

# defmodule Resolvd.Mailbox.InboundPairSupervisor do
#   use DynamicSupervisor

#   require Logger

#   alias Resolvd.Mailbox.InboundProcessor

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

# defmodule Resolvd.Mailbox.YugoStarter do
#   use GenServer

#   def start_link(_start_from, opts) do
#     GenServer.start(Yugo.Client, opts)
#   end

#   def init(init_arg) do
#     {:ok, init_arg}
#   end
# end
