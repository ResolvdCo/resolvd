defmodule ResolvdWeb.ConversationLive.Index do
  use ResolvdWeb, :live_view

  alias Resolvd.Conversations
  alias Resolvd.Conversations.Conversation
  alias Resolvd.Conversations.Message
  alias Resolvd.Accounts
  alias Resolvd.Mailboxes

  alias Resolvd.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :conversations,
       Conversations.list_conversations(socket.assigns.current_user)
       |> Repo.preload([:customer])
     )
     |> assign(:users, Accounts.list_users(socket.assigns.current_user))
     |> assign(:mailboxes, Mailboxes.list_mailboxes(socket.assigns.current_user))}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    conversation = Conversations.get_conversation!(socket.assigns.current_user, id)

    {:noreply, switch_to_conversation(socket, conversation)}
  end

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
    socket
    |> assign(:page_title, "Conversations")
    |> assign(:conversation, nil)
  end

  @impl true
  def handle_info({ResolvdWeb.ConversationLive.FormComponent, {:saved, conversation}}, socket) do
    {:noreply, stream_insert(socket, :conversations, conversation)}
  end

  @impl true
  def handle_info({ResolvdWeb.ConversationLive.MessageComponent, {:saved, message}}, socket) do
    {:noreply, stream_insert(socket, :messages, message)}
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
    |> assign(:page_title, conversation.subject)
    |> stream(:messages, Conversations.list_messages_for_conversation(conversation), reset: true)
  end
end
