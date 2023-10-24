defmodule ResolvdWeb.ConversationLive.HeaderForm do
  require Logger
  use ResolvdWeb, :live_component

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
            <.select
              id="mailbox-select"
              name="mailbox"
              options={@mailbox_options}
              value={@selected_mailbox}
              icon="hero-envelope"
              phx-change="mailbox_changed"
              phx-target={@myself}
            />
          </li>

          <li>
            <.select
              id="assignee-select"
              name="assignee"
              options={@user_options}
              value={@selected_user}
              icon="hero-user"
              phx-change="assignee_changed"
              phx-target={@myself}
            />
          </li>

          <li>
            <ResolvdWeb.Nav.tooltip label="Toggle priority" position="bottom">
              <.checkbox
                id="priority-change"
                name="priority"
                checked={@conversation.is_prioritized}
                class="peer-checked:bg-amber-300 hover:bg-amber-100"
                icon="hero-star"
                phx-change="priority_changed"
                phx-target={@myself}
              />
            </ResolvdWeb.Nav.tooltip>
          </li>

          <li>
            <ResolvdWeb.Nav.tooltip label="Toggle resolved" position="bottom">
              <.checkbox
                id="resolve-change"
                name="resolve"
                checked={@conversation.is_resolved}
                class="peer-checked:bg-green-300 hover:bg-green-100"
                icon="hero-check"
                phx-change="status_changed"
                phx-target={@myself}
              />
            </ResolvdWeb.Nav.tooltip>
          </li>

          <li>
            <ResolvdWeb.Nav.tooltip label="Delete" position="bottom">
              <.checkbox
                id="delete"
                name="delete"
                checked={false}
                class="peer-checked:bg-red-300 hover:bg-red-100"
                icon="hero-trash"
                phx-change="delete_changed"
                phx-target={@myself}
              />
            </ResolvdWeb.Nav.tooltip>
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
     |> assign(:user_options, [{"Not assigned", ""}] ++ make_options_for_select(users))
     |> assign(:selected_user, conversation.user_id)
     |> assign(:mailbox_options, make_options_for_select(mailboxes))
     |> assign(:selected_mailbox, conversation.mailbox_id)}
  end

  @impl true
  def handle_event("mailbox_changed", %{"mailbox" => mailbox_id}, socket) do
    mailbox = Mailboxes.get_mailbox!(socket.assigns.current_user, mailbox_id)
    conversation = Conversations.update_conversation_mailbox(socket.assigns.conversation, mailbox)
    notify_parent({:updated_mailbox, conversation})

    {:noreply, socket}
  end

  def handle_event("assignee_changed", %{"assignee" => user_id}, socket) do
    user = if user_id == "", do: nil, else: Accounts.get_user!(user_id)
    conversation = Conversations.update_conversation_user(socket.assigns.conversation, user)
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

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :options, :list, required: true
  attr :icon, :string, required: true
  attr :value, :any
  attr :rest, :global

  defp select(assigns) do
    ~H"""
    <div class="relative">
      <select id={@id} name={@name} class="pl-8 text-sm rounded-lg border-white shadow" {@rest}>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <.icon name={@icon} class="absolute top-2 left-2" />
    </div>
    """
  end

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :checked, :boolean, required: true
  attr :class, :string, required: true
  attr :icon, :string, required: true
  attr :rest, :global

  defp checkbox(assigns) do
    ~H"""
    <div>
      <input type="hidden" name={@name} value="false" />
      <input
        type="checkbox"
        id={@id}
        name={@name}
        value="true"
        class="peer hidden"
        checked={@checked}
        {@rest}
      />
      <label
        for={@id}
        class={[
          "flex items-center justify-center bg-gray-100 text-gray-700 h-10 w-10 rounded-full hover:cursor-pointer",
          @class
        ]}
      >
        <.icon name={@icon} />
      </label>
    </div>
    """
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp make_options_for_select(options) do
    options |> Enum.map(fn %{id: id, name: name} -> {name, id} end)
  end
end
