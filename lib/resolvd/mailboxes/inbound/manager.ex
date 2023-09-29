defmodule Resolvd.Mailboxes.Inbound.Manager do
  use GenServer

  alias Phoenix.PubSub
  alias Resolvd.Mailboxes
  alias Resolvd.Mailboxes.InboundProviders.IMAPProvider
  alias Resolvd.Mailboxes.Inbound.Supervisor, as: InboundSupervisor

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_child(id, %IMAPProvider{} = server) do
    GenServer.call(__MODULE__, {:start_child, {id, server}})
  end

  defdelegate stop_child(id), to: InboundSupervisor, as: :stop_child
  defdelegate child_started?(id), to: InboundSupervisor, as: :child_started?

  @impl true
  def init(:ok) do
    {:ok, %{}, {:continue, :init_mailboxes}}
  end

  @impl true
  def handle_continue(:init_mailboxes, state) do
    state =
      Mailboxes.all_mailboxes()
      |> Enum.reduce(state, fn mailbox, state ->
        case InboundSupervisor.start_child(mailbox.id, mailbox.inbound_config) do
          {:ok, child} ->
            monitor_mailbox(child, mailbox.id, state)

          _ ->
            state
        end
      end)

    {:noreply, state}
  end

  @impl true
  def handle_call({:start_child, {id, server}}, _from, state) do
    case InboundSupervisor.start_child(id, server) do
      {:ok, child} ->
        {:reply, :ok, monitor_mailbox(child, id, state)}

      _ ->
        {:reply, nil, state}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    case Map.pop(state, ref) do
      {nil, state} ->
        {:noreply, state}

      {mailbox_id, state} ->
        PubSub.broadcast!(Resolvd.PubSub, mailbox_id, {:update_status, false})
        {:noreply, state}
    end
  end

  defp monitor_mailbox(mailbox_pid, mailbox_id, state) do
    ref = Process.monitor(mailbox_pid)
    PubSub.broadcast!(Resolvd.PubSub, mailbox_id, {:update_status, true})
    Map.put(state, ref, mailbox_id)
  end
end
