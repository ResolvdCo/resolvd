defmodule ResolvdWeb.ConversationLive.Index do
  use ResolvdWeb, :live_view

  alias Resolvd.Conversations
  alias Resolvd.Conversations.Conversation
  alias Resolvd.Conversations.Message
  alias Resolvd.Customers.Customer

  alias Resolvd.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     stream(
       socket,
       :conversations,
       Conversations.list_conversations(socket.assigns.current_user) |> Repo.preload([:customer])
     )}
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
    socket
    |> assign(:page_title, "Conversations")
    |> assign(:conversation, nil)
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    conversation = Conversations.get_conversation!(socket.assigns.current_user, id)

    socket
    |> assign(:conversation, conversation)
    |> assign(:message, %Message{})
    |> stream(:messages, conversation.messages)
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

  defp conversation_items do
    [
      %{
        to: ~p"/conversations",
        label: gettext("All"),
        module: ResolvdWeb.ConversationLive
      },
      %{
        to: ~p"/conversations",
        label: gettext("Assigned to me"),
        module: ResolvdWeb.ConversationLive
      },
      %{
        to: ~p"/conversations",
        label: gettext("Unassigned"),
        module: ResolvdWeb.ConversationLive
      },
      %{
        to: ~p"/conversations",
        label: gettext("Prioritized"),
        module: ResolvdWeb.ConversationLive
      },
      %{
        to: ~p"/conversations",
        label: gettext("On hold"),
        module: ResolvdWeb.ConversationLive
      },
      %{
        to: ~p"/conversations",
        label: gettext("Resolved"),
        module: ResolvdWeb.Admin.MailboxLive
      }
    ]
  end

  defp gravatar_avatar(email) do
    hash = :crypto.hash(:md5, email) |> Base.encode16(case: :lower)
    "https://www.gravatar.com/avatar/#{hash}"
  end

  defp display_name(%Customer{} = customer) do
    cond do
      not is_nil(customer.name) -> customer.name
      not is_nil(customer.email) -> customer.email
      not is_nil(customer.phone) -> customer.phone
      true -> "Customer"
    end
  end
end
