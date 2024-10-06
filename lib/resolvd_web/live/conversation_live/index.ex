defmodule ResolvdWeb.ConversationLive.Index do
  use ResolvdWeb, :live_view

  alias ResolvdWeb.Router.Helpers

  alias Resolvd.Conversations
  alias Resolvd.Conversations.Conversation
  alias Resolvd.Conversations.Message
  alias Resolvd.Accounts
  alias Resolvd.Mailboxes

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:users, Accounts.list_users(socket.assigns.current_user))
     |> assign(:mailboxes, Mailboxes.list_mailboxes_for_sidebar(socket.assigns.current_user))
     |> assign(:active_mailbox_id, nil)
     |> assign(:query, "")}
  end

  def conversation_item(assigns) do
    ~H"""

    """
  end

  def render(assigns) do
    ~H"""
    <.header class="text-xl mb-8">Conversations</.header>

    <div id="conversations" phx-update="stream" class="flex flex-col space-y-4">
      <.link
        :for={{dom_id, conversation} <- @streams.conversations}
        id={dom_id}
        navigate={~p"/conversations/#{conversation.id}"}
        class="flex justify-between"
      >
        <div>
          <h3 class="text-lg font-medium"><%= conversation.subject %></h3>
          <p><%= conversation.customer.name %></p>
        </div>
        <div>
          <%= conversation.inserted_at
          |> Timex.format("{relative}", :relative)
          |> elem(1) %>
        </div>
      </.link>
    </div>
    <%!--
    <div class="flex space-x-6">
      <div class="w-1/6">
        <ResolvdWeb.ConversationLive.Components.conversation_categories live_action={@live_action} />
        <nav class="flex flex-1 flex-col" aria-label="Sidebar">
          <ul role="list" class="flex flex-1 flex-col gap-y-7">
            <%!--
            <li>
              <ul role="list" class="-mx-2 space-y-1">
                <li>
                  <!-- Current: "bg-gray-100 text-indigo-600", Default: "text-gray-700 hover:text-indigo-600 hover:bg-gray-100" -->
                  <a
                    href="#"
                    class="bg-gray-100 text-indigo-600 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                  >
                    <svg
                      class="h-6 w-6 shrink-0 text-indigo-600"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M2.25 12l8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25"
                      />
                    </svg>
                    Dashboard
                    <span
                      class="ml-auto w-9 min-w-max whitespace-nowrap rounded-full bg-gray-50 px-2.5 py-0.5 text-center text-xs font-medium leading-5 text-gray-600 ring-1 ring-inset ring-gray-200"
                      aria-hidden="true"
                    >
                      5
                    </span>
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    class="text-gray-700 hover:text-indigo-600 hover:bg-gray-100 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                  >
                    <svg
                      class="h-6 w-6 shrink-0 text-gray-400 group-hover:text-indigo-600"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M15 19.128a9.38 9.38 0 002.625.372 9.337 9.337 0 004.121-.952 4.125 4.125 0 00-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 018.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0111.964-3.07M12 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zm8.25 2.25a2.625 2.625 0 11-5.25 0 2.625 2.625 0 015.25 0z"
                      />
                    </svg>
                    Team
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    class="text-gray-700 hover:text-indigo-600 hover:bg-gray-100 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                  >
                    <svg
                      class="h-6 w-6 shrink-0 text-gray-400 group-hover:text-indigo-600"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M2.25 12.75V12A2.25 2.25 0 014.5 9.75h15A2.25 2.25 0 0121.75 12v.75m-8.69-6.44l-2.12-2.12a1.5 1.5 0 00-1.061-.44H4.5A2.25 2.25 0 002.25 6v12a2.25 2.25 0 002.25 2.25h15A2.25 2.25 0 0021.75 18V9a2.25 2.25 0 00-2.25-2.25h-5.379a1.5 1.5 0 01-1.06-.44z"
                      />
                    </svg>
                    Mailboxes
                    <span
                      class="ml-auto w-9 min-w-max whitespace-nowrap rounded-full bg-gray-50 px-2.5 py-0.5 text-center text-xs font-medium leading-5 text-gray-600 ring-1 ring-inset ring-gray-200"
                      aria-hidden="true"
                    >
                      12
                    </span>
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    class="text-gray-700 hover:text-indigo-600 hover:bg-gray-100 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                  >
                    <svg
                      class="h-6 w-6 shrink-0 text-gray-400 group-hover:text-indigo-600"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 012.25-2.25h13.5A2.25 2.25 0 0121 7.5v11.25m-18 0A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75m-18 0v-7.5A2.25 2.25 0 015.25 9h13.5A2.25 2.25 0 0121 11.25v7.5"
                      />
                    </svg>
                    Calendar
                    <span
                      class="ml-auto w-9 min-w-max whitespace-nowrap rounded-full bg-gray-50 px-2.5 py-0.5 text-center text-xs font-medium leading-5 text-gray-600 ring-1 ring-inset ring-gray-200"
                      aria-hidden="true"
                    >
                      20+
                    </span>
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    class="text-gray-700 hover:text-indigo-600 hover:bg-gray-100 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                  >
                    <svg
                      class="h-6 w-6 shrink-0 text-gray-400 group-hover:text-indigo-600"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M15.75 17.25v3.375c0 .621-.504 1.125-1.125 1.125h-9.75a1.125 1.125 0 01-1.125-1.125V7.875c0-.621.504-1.125 1.125-1.125H6.75a9.06 9.06 0 011.5.124m7.5 10.376h3.375c.621 0 1.125-.504 1.125-1.125V11.25c0-4.46-3.243-8.161-7.5-8.876a9.06 9.06 0 00-1.5-.124H9.375c-.621 0-1.125.504-1.125 1.125v3.5m7.5 10.375H9.375a1.125 1.125 0 01-1.125-1.125v-9.25m12 6.625v-1.875a3.375 3.375 0 00-3.375-3.375h-1.5a1.125 1.125 0 01-1.125-1.125v-1.5a3.375 3.375 0 00-3.375-3.375H9.75"
                      />
                    </svg>
                    Documents
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    class="text-gray-700 hover:text-indigo-600 hover:bg-gray-100 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                  >
                    <svg
                      class="h-6 w-6 shrink-0 text-gray-400 group-hover:text-indigo-600"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M10.5 6a7.5 7.5 0 107.5 7.5h-7.5V6z"
                      />
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M13.5 10.5H21A7.5 7.5 0 0013.5 3v7.5z"
                      />
                    </svg>
                    Reports
                  </a>
                </li>
              </ul>
            </li>
            <li>
              <div class="text-xs font-semibold leading-6 text-gray-400">Mailboxes</div>
              <ul role="list" class="-mx-2 mt-2 space-y-1">
                <li>
                  <.link
                    patch={~p"/conversations"}
                    class={[
                      "group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold",
                      if(@active_mailbox_id == nil,
                        do: "bg-gray-100 text-indigo-600",
                        else: "text-gray-700 hover:text-indigo-600 hover:bg-gray-100"
                      )
                    ]}
                  >
                    <span class={[
                      "flex h-6 w-6 shrink-0 items-center justify-center rounded-lg border text-[0.625rem] font-medium bg-white  group-hover:border-indigo-600 group-hover:text-indigo-600",
                      if(@active_mailbox_id == nil,
                        do: "border-indigo-600 text-indigo-600",
                        else: "text-gray-400 border-gray-200"
                      )
                    ]}>
                      A
                    </span>
                    <span class="truncate">All Mailboxes</span>
                  </.link>
                </li>
                <li :for={{mailbox, count} <- @mailboxes}>
                  <!-- Current: "bg-gray-50 text-indigo-600", Default: "text-gray-700 hover:text-indigo-600 hover:bg-gray-100" -->
                  <!-- Current: "bg-gray-100 text-indigo-600", Default: "text-gray-700 hover:text-indigo-600 hover:bg-gray-100" -->
                  <.link
                    patch={~p"/conversations?mailbox=#{mailbox.id}"}
                    class={[
                      "group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold",
                      if(@active_mailbox_id == mailbox.id,
                        do: "bg-gray-100 text-indigo-600",
                        else: "text-gray-700 hover:text-indigo-600 hover:bg-gray-100"
                      )
                    ]}
                  >
                    <span class={[
                      "flex h-6 w-6 shrink-0 items-center justify-center rounded-lg border text-[0.625rem] font-medium bg-white  group-hover:border-indigo-600 group-hover:text-indigo-600",
                      if(@active_mailbox_id == mailbox.id,
                        do: "border-indigo-600 text-indigo-600",
                        else: "text-gray-400 border-gray-200"
                      )
                    ]}>
                      <%= String.at(mailbox.name, 0) %>
                    </span>
                    <span class="truncate"><%= mailbox.name %></span>
                    <span
                      class="ml-auto w-9 min-w-max whitespace-nowrap rounded-full bg-gray-50 px-2.5 py-0.5 text-center text-xs font-medium leading-5 text-gray-600 ring-1 ring-inset ring-gray-200"
                      aria-hidden="true"
                    >
                      <%= count %>
                    </span>
                  </.link>
                </li>
              </ul>
            </li>
          </ul>
        </nav>
      </div>
      <div class="flex-1">
        <.table
          id="foo"
          rows={@streams.conversations}
          row_click={fn {_id, row} -> JS.navigate(~p"/conversations/#{row.id}") end}
        >
          <:col :let={{row_id, row}} label="Subject">
            <div class="flex items-center text-sm space-x-4">
              <span class="inline-flex h-10 w-10 items-center justify-center rounded-full bg-gray-500">
                <span class="font-medium leading-none text-white">
                  <%= Resolvd.Customers.initials(row.customer) %>
                </span>
              </span>

              <div>
                <p class="text-gray-600 dark:text-gray-400"><%= row.customer.name %></p>
                <p class="font-semibold">
                  <%= row.subject %>
                </p>
              </div>
            </div>
          </:col>
          <:col :let={{row_id, conversation}} :if={is_nil(@active_mailbox_id)} label="Mailbox">
            <%= conversation.mailbox.name %>
          </:col>
          <:col :let={{row_id, row}} label="Status">
            <span
              :if={row.is_resolved}
              class="inline-flex items-center rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20"
            >
              Resolved
            </span>
            <span class="inline-flex items-center rounded-md bg-yellow-50 px-2 py-1 text-xs font-medium text-yellow-800 ring-1 ring-inset ring-yellow-600/20">
              New
            </span>
          </:col>
          <:col :let={{row_id, conversation}} label="Opened">
            <%= conversation.inserted_at
            |> Timex.format("{relative}", :relative)
            |> elem(1) %>
          </:col>
          <:action :let={{row_id, row}}>
            <.link navigate={~p"/conversations/#{row.id}"}>Show</.link>
          </:action>
        </.table>
      </div>
    </div>

    <%!-- <div class="flex flex-shrink-0 w-96 py-4 overflow-hidden pb-0 bg-gray-100">
      <div class="flex flex-col h-full pt-4 w-full">
        <div class="flex items-center px-4">
          <div class="flex items-center">
            <div class="text-xl font-semibold" id="heading"><%= @heading %></div>
            <div class="hidden flex items-center justify-center ml-2 text-xs h-5 w-5 text-white bg-red-500 rounded-full font-medium">
              9+
            </div>
          </div>
          <div class="ml-auto">
            <ResolvdWeb.Utils.tooltip label="New conversation" position="left" class="right-[150%]">
              <button class="flex items-center justify-center h-7 w-7 bg-red-500 text-white rounded-full hover:bg-red-400 active:text-red-600 active:bg-red-200">
                <.icon name="hero-plus-small" class="h-5 w-5" />
              </button>
            </ResolvdWeb.Utils.tooltip>
          </div>
        </div>

        <ResolvdWeb.ConversationLive.Components.conversation_categories live_action={@live_action} />

        <form class="relative flex items-center mb-0" phx-change="search" id="conversation-search">
          <.icon class="left-2 absolute" name="hero-magnifying-glass" />
          <input
            class="placeholder:italic placeholder:text-slate-400 pl-9 bg-white w-full border border-slate-300 shadow-sm focus:outline-none focus:border-sky-500 focus:ring-sky-500 focus:ring-1 focus:ring-inset leading-tight sm:text-sm"
            placeholder="Search conversations..."
            type="text"
            name="query"
            value={@query}
            phx-debounce="500"
          />
        </form>

        <div id="mailbox-filtered" phx-update="stream" class="overflow-y-auto">
          <%= for {dom_id, {mailbox_id, mailbox_name}} <- @streams.conversations  do %>
            <div id={dom_id}>
              <div class="py-2 px-4 sticky top-0 bg-gray-200 z-30">
                <div class="text-xs text-gray-500 font-semibold">
                  <%= mailbox_name %>
                </div>
              </div>
              <ResolvdWeb.ConversationLive.Components.conversation_list
                conversations={@streams[mailbox_id]}
                mailbox_id={mailbox_id}
                conversation={@conversation}
                socket={@socket}
                live_action={@live_action}
                current_user={@current_user}
              />
            </div>
          <% end %>
        </div>
      </div>
    </div>

    <.live_component
      :if={not is_nil(@conversation)}
      module={ResolvdWeb.ConversationLive.ShowMessage}
      title={@page_title}
      id="show_conversation"
      users={@users}
      mailboxes={@mailboxes}
      message={@message}
      current_user={@current_user}
      conversation={@conversation}
      messages={@streams.messages}
    /> --%>
    """
  end

  @impl true
  def handle_params(params, _url, socket) do
    # {:noreply, apply_action(socket, socket.assigns.live_action, params)}
    active_mailbox = Map.get(params, "mailbox", nil)

    {:noreply,
     socket
     |> assign(:active_mailbox_id, active_mailbox)
     |> stream(
       :conversations,
       Conversations.list_conversations_by_mailbox(socket.assigns.current_user, active_mailbox),
       reset: true
     )}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Conversation")
    |> assign(:conversation, Conversations.get_conversation!(socket.assigns.current_user, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Create Conversation")
    |> assign(:conversation, %Conversation{})
  end

  defp apply_action(socket, :index, _params) do
    push_patch(socket, to: ~p"/conversations/all")
  end

  defp apply_action(socket, action, %{"id" => id}) do
    case socket.assigns do
      %{conversation: %Conversation{id: ^id}} ->
        socket

      %{conversation: %Conversation{} = old_conversation} ->
        conversation = Conversations.get_conversation!(socket.assigns.current_user, id)
        switch_to_conversation(socket, conversation, old_conversation)

      _ ->
        conversation = Conversations.get_conversation!(socket.assigns.current_user, id)

        conversations =
          socket.assigns.current_user
          |> Conversations.filter_conversations(action)
          |> Enum.group_by(& &1.mailbox_id)

        socket
        |> stream(:conversations, get_mailbox_id_and_name(conversations))
        |> stream_mailbox_conversations(conversations)
        |> assign(:heading, get_heading(action))
        |> switch_to_conversation(conversation, nil)
    end
  end

  defp apply_action(socket, action, _params) do
    conversations =
      socket.assigns.current_user
      |> Conversations.filter_conversations(action)
      |> Enum.group_by(& &1.mailbox_id)

    socket
    |> stream(:conversations, get_mailbox_id_and_name(conversations))
    |> stream_mailbox_conversations(conversations)
    |> assign(:heading, get_heading(action))
    |> redirect_to_first_conversation(conversations, action)
  end

  @impl true
  def handle_info({ResolvdWeb.ConversationLive.FormComponent, {:saved, conversation}}, socket) do
    {:noreply,
     socket
     |> stream_insert(:conversations, conversation.mailbox_id)
     |> stream_insert(conversation.mailbox_id, conversation)}
  end

  @impl true
  def handle_info(
        {ResolvdWeb.ConversationLive.MessageComponent, {:saved, message, conversation}},
        socket
      ) do
    {:noreply,
     socket
     |> stream_insert(:messages, message)
     |> stream_insert(:conversations, {conversation.mailbox_id, conversation.mailbox.name})
     |> stream_insert(conversation.mailbox_id, conversation)
     |> assign(:conversation, conversation)}
  end

  @impl true
  def handle_info(
        {ResolvdWeb.ConversationLive.HeaderForm, {:updated_mailbox, conversation}},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:conversation, conversation)
     |> stream_insert(:conversations, {conversation.mailbox_id, conversation.mailbox.name})
     |> stream_insert(conversation.mailbox_id, conversation)}
  end

  @impl true
  def handle_info({ResolvdWeb.ConversationLive.HeaderForm, {:updated_user, conversation}}, socket) do
    {:noreply,
     socket
     |> assign(:conversation, conversation)
     |> stream_insert(:conversations, {conversation.mailbox_id, conversation.mailbox.name})
     |> stream_insert(conversation.mailbox_id, conversation)}
  end

  @impl true
  def handle_info(
        {ResolvdWeb.ConversationLive.HeaderForm, {:updated_status, conversation}},
        socket
      ) do
    {:noreply, assign(socket, :conversation, conversation)}
  end

  @impl true
  def handle_info({ResolvdWeb.ConversationLive.HeaderForm, {:unimplemented, event}}, socket) do
    {:noreply, put_flash(socket, :error, "Event: #{event} in not implemented yet")}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    socket =
      case String.trim(query) do
        query when byte_size(query) >= 3 ->
          search_conversations(query, socket)

        _ when byte_size(socket.assigns.query) >= 3 ->
          apply_action(socket, socket.assigns.live_action, %{})

        _ ->
          socket
      end

    {:noreply, assign(socket, :query, String.trim(query))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    conversation = Conversations.get_conversation!(socket.assigns.current_user, id)
    {:ok, _} = Conversations.delete_conversation(conversation)

    {:noreply, stream_delete(socket, :conversations, conversation)}
  end

  defp switch_to_conversation(socket, conversation, nil) do
    socket
    |> apply_assigns(conversation)
    |> push_event("highlight", %{id: "conversations-#{conversation.id}"})
  end

  defp switch_to_conversation(socket, conversation, old_conversation) do
    socket
    |> apply_assigns(conversation)
    |> push_event("highlight", %{id: "conversations-#{conversation.id}"})
    |> push_event("remove-highlight", %{id: "conversations-#{old_conversation.id}"})
  end

  defp apply_assigns(socket, conversation) do
    socket
    |> assign(:conversation, conversation)
    |> assign(:message, %Message{})
    |> assign(:page_title, conversation.subject)
    |> stream(:messages, Conversations.list_messages_for_conversation(conversation), reset: true)
  end

  defp redirect_to_first_conversation(socket, conversations, action) do
    case Map.keys(conversations) do
      [mailbox_id | _] ->
        [conversation | _] = Map.get(conversations, mailbox_id)

        socket
        |> push_patch(to: Helpers.conversation_index_path(socket, action, id: conversation.id))
        |> apply_assigns(conversation)

      _ ->
        socket
        |> assign(:conversation, nil)
        |> assign(:page_title, get_heading(action))
    end
  end

  defp search_conversations(query, socket) do
    conversations =
      socket.assigns.current_user
      |> Conversations.search_conversation(query, socket.assigns.live_action)
      |> Enum.group_by(& &1.mailbox_id)

    socket
    |> stream(:conversations, get_mailbox_id_and_name(conversations))
    |> stream_mailbox_conversations(conversations)
    |> redirect_to_first_conversation(conversations, socket.assigns.live_action)
  end

  defp stream_mailbox_conversations(socket, conversations) do
    streaming_mailboxes = conversations |> Map.keys() |> Enum.into(%MapSet{})

    socket =
      Enum.reduce(socket.assigns.mailboxes, socket, fn mailbox, socket ->
        if MapSet.member?(streaming_mailboxes, mailbox.id),
          do: socket,
          else: stream_delete(socket, :conversations, {mailbox.id, mailbox.name})
      end)

    Enum.reduce(conversations, socket, fn {mailbox_id, convos}, socket ->
      # BUG: Not resetting the list properly. Upstream issue.
      # https://github.com/phoenixframework/phoenix_live_view/issues/2895
      # https://github.com/phoenixframework/phoenix_live_view/issues/2816
      stream(socket, mailbox_id, convos, reset: true)
    end)
  end

  defp get_mailbox_id_and_name(conversations) do
    Enum.map(conversations, fn {mailbox_id, [conversation | _]} ->
      {mailbox_id, conversation.mailbox.name}
    end)
  end

  defp get_heading(action) do
    case action do
      :all -> "All Conversations"
      :me -> "My Conversations"
      :unassigned -> "Unassigned Conversations"
      :prioritized -> "Prioritized Conversations"
      :resolved -> "Resolved Conversations"
    end
  end
end
