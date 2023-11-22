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
     |> stream_configure(:conversations, dom_id: &"mailbox-conversations-#{&1 |> elem(0)}")
     |> stream(:conversations, [])
     |> assign(:users, Accounts.list_users(socket.assigns.current_user))
     |> assign(:mailboxes, Mailboxes.list_mailboxes(socket.assigns.current_user))
     |> assign(:query, "")
     |> set_mailbox_conversation_streams()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
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
    |> stream_mailbox_conversations(conversations)
    |> redirect_to_first_conversation(conversations, socket.assigns.live_action)
  end

  defp set_mailbox_conversation_streams(socket) do
    Enum.reduce(socket.assigns.mailboxes, socket, fn mailbox, socket ->
      socket
      |> stream_configure(mailbox.id, dom_id: &"conversations-#{&1.id}")
      |> stream(mailbox.id, [])
    end)
  end

  defp stream_mailbox_conversations(socket, conversations) do
    streaming_mailboxes = conversations |> Map.keys() |> Enum.into(%MapSet{})

    socket =
      Enum.reduce(socket.assigns.mailboxes, socket, fn mailbox, socket ->
        if MapSet.member?(streaming_mailboxes, mailbox.id),
          do: stream_insert(socket, :conversations, {mailbox.id, mailbox.name}),
          else: stream_delete(socket, :conversations, {mailbox.id, mailbox.name})
      end)

    Enum.reduce(conversations, socket, fn {mailbox_id, convos}, socket ->
      # BUG: Not resetting the list properly. Upstream issue.
      # https://github.com/phoenixframework/phoenix_live_view/issues/2895
      # https://github.com/phoenixframework/phoenix_live_view/issues/2816
      stream(socket, mailbox_id, convos, reset: true)
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
