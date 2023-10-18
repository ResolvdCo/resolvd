defmodule ResolvdWeb.ConversationLive.ShowMessage do
  use ResolvdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-full w-full bg-white px-4 pt-6">
      <ResolvdWeb.ConversationLive.Components.header
        conversation={@conversation}
        mailboxes={@mailboxes}
        users={@users}
      />

      <div class="flex h-full overflow-hidden">
        <div class="flex flex-col w-full">
          <ResolvdWeb.ConversationLive.Components.messages
            messages={@messages}
            conversation={@conversation}
          />

          <.live_component
            module={ResolvdWeb.ConversationLive.MessageComponent}
            id={:new}
            message={@message}
            action={:new}
            conversation={@conversation}
            current_user={@current_user}
          />
        </div>

        <ResolvdWeb.ConversationLive.Components.details conversation={@conversation} />
      </div>
    </div>
    """
  end
end
