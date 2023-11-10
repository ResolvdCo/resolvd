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
      >
        <.live_component
          module={ResolvdWeb.ConversationLive.HeaderForm}
          id="header_form"
          users={@users}
          mailboxes={@mailboxes}
          conversation={@conversation}
          current_user={@current_user}
        />
      </ResolvdWeb.ConversationLive.Components.header>

      <div class="flex h-full overflow-hidden">
        <div class="flex flex-col w-full">
          <ResolvdWeb.ConversationLive.Components.messages messages={@messages} />

          <.live_component
            module={ResolvdWeb.ConversationLive.MessageComponent}
            id={:new}
            message={@message}
            action={:new}
            conversation={@conversation}
            current_user={@current_user}
          />
        </div>

        <ResolvdWeb.ConversationLive.Components.details
          conversation={@conversation}
          current_user={@current_user}
        />
      </div>
    </div>
    """
  end
end
