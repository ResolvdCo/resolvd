defmodule ResolvdWeb.ConversationLive.Show do
  use ResolvdWeb, :live_view

  alias Resolvd.Conversations
  alias Resolvd.Conversations.Message

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    conversation = Conversations.get_conversation!(socket.assigns.current_user, id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:conversation, conversation)
     |> assign(:message, %Message{})
     |> stream(:messages, Conversations.list_messages_for_conversation(conversation))}
  end

  @impl true
  def handle_info({ResolvdWeb.ConversationLive.MessageComponent, {:saved, message}}, socket) do
    {:noreply, stream_insert(socket, :messages, message)}
  end

  defp page_title(:show), do: "Show Conversation"
  defp page_title(:edit), do: "Edit Conversation"

  defp message_body(%Message{html_body: body}) when not is_nil(body) do
    raw(String.replace(body, "\r", "<br>"))
  end

  defp message_body(%Message{text_body: body}) when not is_nil(body) do
    raw(String.replace(body, "\r", "<br>"))
  end

  defp message_body(_) do
    "~~~"
  end

  defp gravatar_avatar(email) do
    hash = :crypto.hash(:md5, email) |> Base.encode16(case: :lower)
    "https://www.gravatar.com/avatar/#{hash}"
  end
end
