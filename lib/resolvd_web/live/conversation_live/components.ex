defmodule ResolvdWeb.ConversationLive.Components do
  use ResolvdWeb, :html

  alias ResolvdWeb.Utils
  alias ResolvdWeb.Router.Helpers
  alias Resolvd.Conversations.Message
  alias Resolvd.Conversations.Conversation

  attr :live_action, :atom, required: true

  def conversation_categories(assigns) do
    ~H"""
    <ul class="-mx-2 mt-2 space-y-1">
      <li :for={item <- conversation_items()}>
        <.link
          navigate={item.to}
          class={[
            "group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold",
            if(item.action == @live_action,
              do: "bg-gray-100 text-indigo-600",
              else: "text-gray-700 hover:text-indigo-600 hover:bg-gray-100"
            )
          ]}
        >
          <span class="whitespace-nowrap">
            <%= item.label %>
          </span>
        </.link>
      </li>
    </ul>
    """
  end

  attr :conversations, :any, required: true
  attr :mailbox_id, :string, required: true
  attr :conversation, :map, required: true
  attr :socket, :any, required: true
  attr :live_action, :atom, required: true
  attr :current_user, :any, required: true

  def conversation_list(assigns) do
    ~H"""
    <div class="relative shadow-inner">
      <div class="flex flex-col w-full" id={"mailbox-list-#{@mailbox_id}"} phx-update="stream">
        <%= for {dom_id, conversation} <- @conversations do %>
          <.link
            id={dom_id}
            patch={Helpers.conversation_index_path(@socket, @live_action, id: conversation.id)}
            class={[
              "flex flex-row items-center p-4 border-l-2 from-red-100 to-transparent",
              if(active_conversation?(conversation, @conversation),
                do: "bg-gradient-to-r border-x-red-500",
                else: "hover:bg-gradient-to-r hover:border-x-red-100"
              )
            ]}
          >
            <Utils.profile_picture email={conversation.customer.email} />
            <div class="flex flex-col justify-between h-10 w-72 ml-2">
              <div class="flex justify-between items-center space-x-5">
                <h1 class={[
                  "text-sm font-medium truncate",
                  if(active_conversation?(conversation, @conversation),
                    do: "text-gray-800",
                    else: "text-gray-700"
                  )
                ]}>
                  <%= Utils.display_name(conversation.customer) %>
                </h1>
                <span class="text-xs whitespace-nowrap text-gray-500">
                  <%= conversation.updated_at
                  |> Timex.format("{relative}", :relative)
                  |> elem(1) %>
                </span>
              </div>

              <div class="flex justify-between items-center space-x-5">
                <p class={[
                  "text-xs truncate w-64",
                  if(active_conversation?(conversation, @conversation),
                    do: "text-gray-700",
                    else: "text-gray-600"
                  )
                ]}>
                  <%= conversation.subject %>
                </p>
                <%= if @live_action in [:all, :prioritized] do %>
                  <%= case conversation.user_id do %>
                    <% nil -> %>
                      <% nil %>
                    <% user_id when user_id == @current_user.id  -> %>
                      <Utils.tooltip
                        label={"Assigned to #{@current_user.name}"}
                        position="left"
                        class="right-[150%]"
                      >
                        <.icon name="hero-user-solid h-4 w-4 bg-blue-500" />
                      </Utils.tooltip>
                    <% _ -> %>
                      <Utils.tooltip
                        label={"Assigned to #{conversation.user.name}"}
                        position="left"
                        class="right-[150%]"
                      >
                        <.icon name="hero-user-solid h-4 w-4" />
                      </Utils.tooltip>
                  <% end %>
                <% end %>
              </div>
            </div>
          </.link>
        <% end %>
      </div>
    </div>
    """
  end

  attr :conversation, :map, required: true
  attr :mailboxes, :any, required: true
  attr :users, :any, required: true
  slot :inner_block, required: true

  def header(assigns) do
    ~H"""
    <div class="z-30 flex items-center py-4 px-6 rounded-2xl shadow-md justify-between space-x-5">
      <div class="flex overflow-hidden">
        <Utils.profile_picture email={@conversation.customer.email} />
        <div class="flex flex-col ml-3 overflow-hidden">
          <p class="font-semibold text-sm truncate">
            <%= Utils.display_name(@conversation.customer) %>
          </p>
          <p class="text-sm text-gray-700 whitespace-nowrap truncate">
            <%= @conversation.subject %>
          </p>
        </div>
      </div>
      <div>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  attr :messages, :any, required: true

  def messages(assigns) do
    ~H"""
    <div class="flex h-full py-4 overflow-hidden -my-4">
      <div class="h-full w-full overflow-y-auto">
        <div class="grid grid-cols-12 gap-y-2 py-4" id="messages" phx-update="stream">
          <%= for {dom_id, message} <- @messages do %>
            <%= if is_nil(message.user) do %>
              <div class="col-start-1 col-end-8 p-3 rounded-lg" id={dom_id}>
                <div class="flex flex-row items-center">
                  <Utils.profile_picture email={message.customer.email} />
                  <div class="relative ml-3 text-sm bg-blue-50 py-2 px-4 shadow rounded-xl">
                    <.message message={message} />
                    <div class="absolute text-xs bottom-0 left-0 -mb-5 ml-2 text-gray-500 whitespace-nowrap">
                      <%= message.inserted_at
                      |> Timex.format("{relative}", :relative)
                      |> elem(1) %>
                    </div>
                  </div>
                </div>
              </div>
            <% else %>
              <div class="col-start-6 col-end-13 p-3 rounded-lg" id={dom_id}>
                <div class="flex items-center justify-start flex-row-reverse">
                  <Utils.profile_picture email={message.user.email} />
                  <div class="relative mr-3 text-sm bg-indigo-100 py-2 px-4 shadow rounded-xl">
                    <.message message={message} />
                    <div class="absolute text-xs bottom-0 right-0 -mb-5 mr-2 text-gray-500 whitespace-nowrap">
                      <%= message.inserted_at
                      |> Timex.format("{relative}", :relative)
                      |> elem(1) %>
                    </div>
                  </div>
                </div>
              </div>
            <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  attr :message, :string, required: true

  def message(assigns) do
    ~H"""
    <%= case @message do %>
      <% %Message{text_body: body} when not is_nil(body) -> %>
        <div class="whitespace-pre-line"><%= String.trim(body) %></div>
      <% %Message{html_body: body} when not is_nil(body) -> %>
        <iframe srcdoc={body} id={@message.id} phx-hook="DisplayMessage" />
      <% _ -> %>
        <div>~~~</div>
    <% end %>
    """
  end

  attr :conversation, :map, required: true
  attr :current_user, :map, required: true

  def details(assigns) do
    ~H"""
    <div class="flex flex-col rounded-2xl shadow-inner mt-4 gap-y-4 ml-2 w-96 mb-4 bg-gray-50 overflow-hidden">
      <h1 class="text-lg font-medium pl-4 pt-4 text-gray-700">Details</h1>
      <div class="flex flex-col rounded-lg shadow mx-2 p-2 gap-y-1 bg-white oveflow-hidden">
        <h1 class="font-normal text-md truncate pb-2 pl-2">
          <%= Utils.display_name(@conversation.customer) %>
        </h1>
        <div class="flex items-center space-x-2 pl-2">
          <.icon name="hero-envelope" />
          <p class="truncate text-sm"><%= Utils.display_info(@conversation.customer.email) %></p>
        </div>
        <div class="flex items-center space-x-2 pl-2">
          <.icon name="hero-phone" />
          <p class="truncate text-sm"><%= Utils.display_info(@conversation.customer.phone) %></p>
        </div>
      </div>

      <div
        class="flex flex-col rounded-lg shadow mx-2 p-2 gap-y-1 bg-white oveflow-hidden"
        id="conversation-details"
      >
        <h1 class="font-normal text-md truncate pb-2 pl-2">Conversation Details</h1>
        <div class="flex items-center space-x-2 pl-2">
          <span class="font-medium text-sm">Status: </span>
          <Utils.conversation_status conversation={@conversation} />
        </div>
        <div class="flex items-center space-x-2 pl-2">
          <span class="font-medium text-sm">Assignee: </span>
          <p class="truncate text-sm">
            <Utils.assigned_user conversation={@conversation} current_user={@current_user} />
          </p>
        </div>
        <div class="flex items-center space-x-2 pl-2">
          <span class="font-medium text-sm">Mailbox: </span>
          <span class="flex flex-row gap-1 truncate items-center">
            <.icon name="hero-envelope" />
            <p class="text-sm truncate"><%= @conversation.mailbox.name %></p>
          </span>
        </div>
      </div>

      <div class="flex flex-col rounded-lg shadow mx-2 p-2 gap-y-1 bg-white oveflow-hidden">
        <h1 class="font-normal text-md truncate pb-2 pl-2">Latest Conversations</h1>
        <div class="flex items-center space-x-2 pl-2">
          <div class="rounded-full h-2 w-2 bg-green-500"></div>
          <p class="truncate text-sm">A resolved conversation</p>
        </div>
        <div class="flex items-center space-x-2 pl-2">
          <div class="rounded-full h-2 w-2 bg-amber-500"></div>
          <p class="truncate text-sm">A prioritized conversation</p>
        </div>
        <div class="flex items-center space-x-2 pl-2">
          <div class="rounded-full h-2 w-2 bg-indigo-500"></div>
          <p class="truncate text-sm">An open conversation</p>
        </div>
        <div class="flex items-center px-2 py-2 space-x-2">
          <Utils.conversation_status conversation={%Conversation{is_resolved: true}} />
          <Utils.conversation_status conversation={%Conversation{is_prioritized: true}} />
          <Utils.conversation_status conversation={%Conversation{}} />
        </div>
      </div>
    </div>
    """
  end

  def message_box(assigns) do
    ~H"""
    <div class="z-30 flex flex-row items-center pb-4 pr-4">
      <div class="flex flex-row items-center w-full border rounded-full min-h-12 px-2 shadow">
        <button class="flex items-center justify-center h-10 w-10 text-gray-400 ml-1">
          <.icon name="hero-paper-clip" class="w-5 h-5" />
        </button>
        <div class="w-full pr-8">
          <textarea
            phx-change={JS.dispatch("phx:input")}
            class="border border-transparent w-full focus:outline-none focus:ring-0 text-sm flex max-h-24 h-10 resize-none items-center"
            placeholder="Type your message...."
          />
        </div>
      </div>
      <div class="ml-6">
        <button class="bg-blue-500 flex items-center justify-center h-10 w-10 rounded-full bg-gray-200 hover:bg-gray-300 text-indigo-800 text-white">
          <.icon name="hero-paper-airplane-solid" class="w-5 h-5" />
        </button>
      </div>
    </div>
    """
  end

  defp conversation_items do
    [
      %{
        to: ~p"/conversations/all",
        label: gettext("Inbox"),
        action: :all
      },
      # %{
      #   to: ~p"/conversations/me",
      #   label: gettext("Me"),
      #   action: :me
      # },
      %{
        to: ~p"/conversations/unassigned",
        label: gettext("Unassigned"),
        action: :unassigned
      },
      %{
        to: ~p"/conversations/prioritized",
        label: gettext("Prioritized"),
        action: :prioritized
      },
      %{
        to: ~p"/conversations/resolved",
        label: gettext("Resolved"),
        action: :resolved
      }
    ]
  end

  defp active_conversation?(element, conversation) do
    not is_nil(conversation) and element.id == conversation.id
  end
end
