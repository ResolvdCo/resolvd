defmodule ResolvdWeb.ConversationLive.HeaderForm do
  require Logger

  use ResolvdWeb, :live_component

  alias ResolvdWeb.Utils
  alias Resolvd.Conversations
  alias Resolvd.Mailboxes
  alias Resolvd.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <form>
        <ul class="flex flex-row items-center space-x-2">
          <li>
            <Utils.select
              id="mailbox-select"
              name="mailbox"
              options={@mailbox_options}
              value={@selected_mailbox}
              phx-change="mailbox_changed"
              phx-target={@myself}
            >
              <Utils.envelope_icon />
            </Utils.select>
          </li>

          <li>
            <Utils.select
              id="assignee-select"
              name="assignee"
              options={@user_options}
              value={@selected_user}
              phx-change="assignee_changed"
              phx-target={@myself}
            >
              <Utils.user_icon user_id={@selected_user} current_user={@current_user} />
            </Utils.select>
          </li>

          <li>
            <Utils.tooltip label="Toggle priority" position="bottom">
              <Utils.checkbox
                id="priority-change"
                name="priority"
                checked={@conversation.is_prioritized}
                class="peer-checked:bg-amber-100 hover:bg-amber-50"
                phx-change="priority_changed"
                phx-target={@myself}
              >
                <Utils.prioritize_icon prioritized?={@conversation.is_prioritized} />
              </Utils.checkbox>
            </Utils.tooltip>
          </li>

          <li>
            <Utils.tooltip label="Toggle resolved" position="bottom">
              <Utils.checkbox
                id="resolve-change"
                name="resolve"
                checked={@conversation.is_resolved}
                class="peer-checked:bg-green-100 hover:bg-green-50"
                phx-change="status_changed"
                phx-target={@myself}
              >
                <Utils.resolved_icon resolved?={@conversation.is_resolved} />
              </Utils.checkbox>
            </Utils.tooltip>
          </li>

          <li>
            <Utils.tooltip label="Delete" position="bottom">
              <Utils.checkbox
                id="delete"
                name="delete"
                checked={false}
                class="peer-checked:bg-red-100 hover:bg-red-50"
                phx-change="delete_changed"
                phx-target={@myself}
              >
                <.icon name="hero-trash" />
              </Utils.checkbox>
            </Utils.tooltip>
          </li>
        </ul>
      </form>
    </div>
    """
  end

  @impl true
  def update(%{users: users, mailboxes: mailboxes, conversation: conversation} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:user_options, [{"Not assigned", ""}] ++ Utils.make_options_for_select(users))
     |> assign(:selected_user, conversation.user_id)
     |> assign(:mailbox_options, Utils.make_options_for_select(mailboxes))
     |> assign(:selected_mailbox, conversation.mailbox_id)}
  end

  @impl true
  def handle_event("mailbox_changed", %{"mailbox" => mailbox_id}, socket) do
    mailbox = Mailboxes.get_mailbox!(socket.assigns.current_user, mailbox_id)
    conversation = Conversations.update_conversation_mailbox(socket.assigns.conversation, mailbox)
    conversation = Conversations.get_conversation!(socket.assigns.current_user, conversation.id)
    notify_parent({:updated_mailbox, conversation})

    {:noreply, socket}
  end

  def handle_event("assignee_changed", %{"assignee" => user_id}, socket) do
    user = if user_id == "", do: nil, else: Accounts.get_user!(user_id)
    conversation = Conversations.update_conversation_user(socket.assigns.conversation, user)
    conversation = Conversations.get_conversation!(socket.assigns.current_user, conversation.id)
    notify_parent({:updated_user, conversation})

    {:noreply, socket}
  end

  def handle_event("priority_changed", %{"priority" => priority}, socket) do
    conversation = Conversations.set_priority(socket.assigns.conversation, priority == "true")

    notify_parent({:updated_status, conversation})

    {:noreply, socket}
  end

  def handle_event("status_changed", %{"resolve" => resolved}, socket) do
    conversation = Conversations.set_resolved(socket.assigns.conversation, resolved == "true")

    notify_parent({:updated_status, conversation})

    {:noreply, socket}
  end

  def handle_event(event, _unsigned_params, socket) do
    notify_parent({:unimplemented, event})
    {:noreply, socket}
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
