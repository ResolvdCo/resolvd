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
     |> stream(:conversations, [])
     |> assign(:users, Accounts.list_users(socket.assigns.current_user))
     |> assign(:mailboxes, Mailboxes.list_mailboxes(socket.assigns.current_user))}
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

      %{conversation: %Conversation{}} ->
        conversation = Conversations.get_conversation!(socket.assigns.current_user, id)
        switch_to_conversation(socket, conversation)

      _ ->
        conversation = Conversations.get_conversation!(socket.assigns.current_user, id)
        conversations = get_conversations_function(action).(socket.assigns.current_user)

        socket
        |> stream(:conversations, conversations)
        |> assign(:heading, get_heading(action))
        |> switch_to_conversation(conversation)
    end
  end

  defp apply_action(socket, action, _params) do
    conversations = get_conversations_function(action).(socket.assigns.current_user)

    socket
    |> stream(:conversations, conversations)
    |> assign(:heading, get_heading(action))
    |> redirect_to_first_conversation(conversations, action)
  end

  @impl true
  def handle_info({ResolvdWeb.ConversationLive.FormComponent, {:saved, conversation}}, socket) do
    {:noreply, stream_insert(socket, :conversations, conversation)}
  end

  @impl true
  def handle_info(
        {ResolvdWeb.ConversationLive.MessageComponent, {:saved, message, conversation}},
        socket
      ) do
    {:noreply, socket |> stream_insert(:messages, message) |> assign(:conversation, conversation)}
  end

  @impl true
  def handle_info(
        {ResolvdWeb.ConversationLive.HeaderForm, {:updated_mailbox, conversation}},
        socket
      ) do
    {:noreply, assign(socket, :conversation, conversation)}
  end

  @impl true
  def handle_info({ResolvdWeb.ConversationLive.HeaderForm, {:updated_user, conversation}}, socket) do
    {:noreply, assign(socket, :conversation, conversation)}
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
  def handle_event("delete", %{"id" => id}, socket) do
    conversation = Conversations.get_conversation!(socket.assigns.current_user, id)
    {:ok, _} = Conversations.delete_conversation(conversation)

    {:noreply, stream_delete(socket, :conversations, conversation)}
  end

  # FIXME: Swiching conversation quickly when the previous request hasn't
  # completed doesn't remove the highlight from the old conversation
  defp switch_to_conversation(socket, conversation) do
    # Update new conversation and old conversation in the stream when:
    # - Conversation stream is empty
    # - Old conversation exists
    # - Old conversation is different from new conversation
    with [] <- socket.assigns.streams.conversations.inserts,
         %Conversation{} = old_conversation when old_conversation != conversation <-
           Map.get(socket.assigns, :conversation) do
      socket
      |> stream_insert(:conversations, conversation)
      |> stream_insert(:conversations, old_conversation)
      |> apply_assigns(conversation)
    else
      # Return the socket if conversation doesn't change
      ^conversation ->
        socket

      # Insert new conversation when old conversation doesn't exist
      nil ->
        socket
        |> stream_insert(:conversations, conversation)
        |> apply_assigns(conversation)

      # New mount
      _ ->
        apply_assigns(socket, conversation)
    end
  end

  defp apply_assigns(socket, conversation) do
    socket
    |> assign(:conversation, conversation)
    |> assign(:message, %Message{})
    |> assign(:page_title, Mailboxes.parse_mime_encoded_word(conversation.subject))
    |> stream(:messages, Conversations.list_messages_for_conversation(conversation), reset: true)
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

  defp get_conversations_function(action) do
    case action do
      :all -> &Conversations.list_unresolved_conversations/1
      :me -> &Conversations.list_conversations_assigned_to_me/1
      :unassigned -> &Conversations.list_unassigned_conversations/1
      :prioritized -> &Conversations.list_prioritized_conversations/1
      :resolved -> &Conversations.list_resolved_conversations/1
    end
  end

  defp redirect_to_first_conversation(socket, [conversation | _], action) do
    socket
    |> push_patch(to: Helpers.conversation_index_path(socket, action, id: conversation.id))
    |> apply_assigns(conversation)
  end

  defp redirect_to_first_conversation(socket, _conversations, action) do
    socket
    |> assign(:conversation, nil)
    |> assign(:page_title, get_heading(action))
  end
end
