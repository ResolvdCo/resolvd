defmodule ResolvdWeb.ConversationLive.Index do
  use ResolvdWeb, :live_view

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
  def handle_params(%{"id" => id} = params, url, socket) do
    conversation = Conversations.get_conversation!(socket.assigns.current_user, id)

    socket =
      case socket.assigns do
        %{path: path} when not is_nil(path) ->
          socket

        _ ->
          path = url |> URI.parse() |> Map.get(:path)

          socket
          |> assign(:path, path)
          |> apply_action(socket.assigns.live_action, params)
      end

    {:noreply, switch_to_conversation(socket, conversation)}
  end

  def handle_params(params, url, socket) do
    socket = assign(socket, :path, url |> URI.parse() |> Map.get(:path))
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

  defp apply_action(socket, :all, params) do
    conversations = Conversations.list_unresolved_conversations(socket.assigns.current_user)

    socket
    |> redirect_to_first_conversation(conversations, params)
    |> stream(:conversations, conversations)
    |> assign(:page_title, "All Conversations")
    |> assign(:filter, "All Conversations")
    |> assign(:conversation, nil)
  end

  defp apply_action(socket, :me, params) do
    conversations = Conversations.list_conversations_assigned_to_me(socket.assigns.current_user)

    socket
    |> redirect_to_first_conversation(conversations, params)
    |> stream(:conversations, conversations)
    |> assign(:page_title, "My Conversations")
    |> assign(:filter, "My Conversations")
    |> assign(:conversation, nil)
  end

  defp apply_action(socket, :unassigned, params) do
    conversations = Conversations.list_unassigned_conversations(socket.assigns.current_user)

    socket
    |> redirect_to_first_conversation(conversations, params)
    |> stream(:conversations, conversations)
    |> assign(:page_title, "Unassigned Conversations")
    |> assign(:filter, "Unassigned Conversations")
    |> assign(:conversation, nil)
  end

  defp apply_action(socket, :prioritized, params) do
    conversations = Conversations.list_prioritized_conversations(socket.assigns.current_user)

    socket
    |> redirect_to_first_conversation(conversations, params)
    |> stream(:conversations, conversations)
    |> assign(:page_title, "Prioritized Conversations")
    |> assign(:filter, "Prioritized Conversations")
    |> assign(:conversation, nil)
  end

  defp apply_action(socket, :resolved, params) do
    conversations = Conversations.list_resolved_conversations(socket.assigns.current_user)

    socket
    |> redirect_to_first_conversation(conversations, params)
    |> stream(:conversations, conversations)
    |> assign(:page_title, "Resolved Conversations")
    |> assign(:filter, "Resolved Conversations")
    |> assign(:conversation, nil)
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

  defp redirect_to_first_conversation(socket, _conversations, %{"id" => _}), do: socket

  defp redirect_to_first_conversation(socket, [conversation | _], _params) do
    push_patch(socket, to: "#{socket.assigns.path}?id=#{conversation.id}")
  end

  defp redirect_to_first_conversation(socket, _conversations, _params), do: socket
end
