defmodule ResolvdWeb.ConversationLive.Components do
  use ResolvdWeb, :html

  alias Resolvd.Conversations.Message
  alias Resolvd.Customers.Customer

  def conversation_categories(assigns) do
    ~H"""
    <div class="mt-5">
      <ul class="flex flex-row items-baseline justify-between">
        <li :for={item <- conversation_items()}>
          <.link
            navigate={item.to}
            class="flex flex-col items-center pb-3 text-xs font-semibold text-gray-700"
          >
            <span class="whitespace-nowrap">
              <%= item.label %>
            </span>

            <span :if={item.label == "All"} class="h-1 w-full bg-gray-800 rounded-full"></span>
          </.link>
        </li>
      </ul>
    </div>
    """
  end

  attr :conversations, :any, required: true
  attr :conversation, :map, required: true

  def conversation_list(assigns) do
    ~H"""
    <div class="h-full overflow-hidden relative -ml-4 -mr-10 px-4 shadow-inner">
      <div
        class="flex flex-col h-full w-full overflow-y-auto -mx-4"
        id="conversations"
        phx-update="stream"
      >
        <%= for {dom_id, conversation} <- @conversations do %>
          <.link
            id={dom_id}
            patch={~p"/conversations?id=#{conversation}"}
            class={[
              "flex flex-row items-center p-4 border-l-2",
              if(active_conversation?(conversation, @conversation),
                do: "bg-gradient-to-r from-red-100 to-transparent border-x-red-500",
                else: "hover:bg-gradient-to-r from-red-100 to-transparent hover:border-x-red-100"
              )
            ]}
          >
            <img
              class="object-cover w-10 h-10 rounded-full"
              src={gravatar_avatar(conversation.customer.email)}
              alt=""
            />
            <div class="flex flex-col justify-between h-10 w-72 ml-2">
              <div class="flex justify-between items-center space-x-5">
                <h1 class={[
                  "text-sm font-medium truncate",
                  if(active_conversation?(conversation, @conversation),
                    do: "text-gray-800",
                    else: "text-gray-700"
                  )
                ]}>
                  <%= display_name(conversation.customer) %>
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
                <div class="hidden h-1 w-1 p-1 bg-red-500 rounded-full"></div>
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

  def header(assigns) do
    ~H"""
    <div class="z-30 flex items-center py-4 px-6 rounded-2xl shadow-md justify-between space-x-5">
      <div class="flex overflow-hidden">
        <img
          class="object-cover w-10 h-10 rounded-full"
          src={gravatar_avatar(@conversation.customer.email)}
          alt=""
        />
        <div class="flex flex-col ml-3 overflow-hidden">
          <p class="font-semibold text-sm truncate">
            <%= display_name(@conversation.customer) %>
          </p>
          <p class="text-sm text-gray-700 whitespace-nowrap truncate">
            <%= @conversation.subject %>
          </p>
        </div>
      </div>
      <div>
        <ul class="flex flex-row items-center space-x-2">
          <li>
            <div class="relative">
              <select id="mailbox" class="pl-8 text-sm rounded-lg border-white shadow">
                <%= for mailbox <- @mailboxes do %>
                  <%= if mailbox.id == @conversation.mailbox_id do %>
                    <option id={"mailboxes-#{mailbox.id}"} selected>
                      <%= mailbox.name %>
                    </option>
                  <% else %>
                    <option id={"mailboxes-#{mailbox.id}"}>
                      <%= mailbox.name %>
                    </option>
                  <% end %>
                <% end %>
              </select>
              <.icon name="hero-envelope" class="absolute top-2 left-2" />
            </div>
          </li>

          <li>
            <div class="relative">
              <select id="user" class="pl-8 text-sm rounded-lg border-white shadow">
                <option id="none">Not assigned</option>
                <%= for user <- @users do %>
                  <%= if user.id == @conversation.user_id do %>
                    <option id={"users-#{user.id}"} selected>
                      <%= user.name %>
                    </option>
                  <% else %>
                    <option id={"users-#{user.id}"}>
                      <%= user.name %>
                    </option>
                  <% end %>
                <% end %>
              </select>
              <.icon name="hero-user" class="absolute top-2 left-2" />
            </div>
          </li>

          <li>
            <a
              href="#"
              class="flex items-center justify-center bg-gray-100 hover:bg-gray-200 text-gray-700 h-10 w-10 rounded-full"
            >
              <.icon name="hero-star" />
            </a>
          </li>
          <li>
            <a
              href="#"
              class="flex items-center justify-center bg-gray-100 hover:bg-gray-200 text-gray-700 h-10 w-10 rounded-full"
            >
              <.icon name="hero-check" />
            </a>
          </li>
          <li>
            <a
              href="#"
              class="flex items-center justify-center bg-gray-100 hover:bg-gray-200 text-gray-700 h-10 w-10 rounded-full"
            >
              <.icon name="hero-trash" />
            </a>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  attr :messages, :any, required: true
  attr :conversation, :map, required: true

  def messages(assigns) do
    ~H"""
    <div class="flex h-full py-4 overflow-hidden -my-4">
      <div class="h-full w-full overflow-y-auto">
        <div class="grid grid-cols-12 gap-y-2 py-4" id="messages" phx-update="stream">
          <%= for {dom_id, message} <- @messages do %>
            <%= if is_nil(message.user_id) do %>
              <div class="col-start-1 col-end-8 p-3 rounded-lg" id={dom_id}>
                <div class="flex flex-row items-center">
                  <img
                    class="object-cover w-10 h-10 rounded-full"
                    src={gravatar_avatar(@conversation.customer.email)}
                    alt=""
                  />
                  <div class="relative ml-3 text-sm bg-blue-50 py-2 px-4 shadow rounded-xl">
                    <div><%= message_body(message) %></div>
                    <div class="absolute text-xs bottom-0 left-0 -mb-5 ml-2 text-gray-500">
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
                  <img
                    class="object-cover w-10 h-10 rounded-full"
                    src={gravatar_avatar(@conversation.user.email)}
                    alt=""
                  />
                  <div class="relative mr-3 text-sm bg-indigo-100 py-2 px-4 shadow rounded-xl">
                    <div><%= message_body(message) %></div>
                    <div class="absolute text-xs bottom-0 right-0 -mb-5 mr-2 text-gray-500">
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

  attr :conversation, :map, required: true

  def details(assigns) do
    ~H"""
    <div class="flex flex-col rounded-2xl shadow-inner mt-4 gap-y-4 ml-2 w-96 mb-4 bg-gray-50 overflow-hidden">
      <h1 class="text-lg font-medium pl-4 pt-4 text-gray-700">Details</h1>
      <div class="flex flex-col rounded-lg shadow mx-2 p-2 gap-y-1 bg-white oveflow-hidden">
        <h1 class="font-normal text-md truncate pb-2 pl-2">
          <%= display_name(@conversation.customer) %>
        </h1>
        <div class="flex items-center space-x-2 pl-2">
          <.icon name="hero-envelope" />
          <p class="truncate text-sm"><%= display_info(@conversation.customer.email) %></p>
        </div>
        <div class="flex items-center space-x-2 pl-2">
          <.icon name="hero-phone" />
          <p class="truncate text-sm"><%= display_info(@conversation.customer.phone) %></p>
        </div>
      </div>

      <div class="flex flex-col rounded-lg shadow mx-2 p-2 gap-y-1 bg-white oveflow-hidden">
        <h1 class="font-normal text-md truncate pb-2 pl-2">Conversation Details</h1>
        <div class="flex items-center space-x-2 pl-2">
          <span class="font-medium text-sm">Status: </span>
          <span class="truncate text-sm bg-indigo-300 p-1 leading-3">Open</span>
        </div>
        <div class="flex items-center space-x-2 pl-2">
          <span class="font-medium text-sm">Assignee: </span>
          <p class="truncate text-sm"><%= @conversation.user_id || "Not assigned" %></p>
        </div>
        <div class="flex items-center space-x-2 pl-2">
          <span class="font-medium text-sm">Inbox: </span>
          <p class="truncate text-sm"><%= @conversation.mailbox_id %></p>
        </div>
      </div>

      <div class="flex flex-col rounded-lg shadow mx-2 p-2 gap-y-1 bg-white oveflow-hidden">
        <h1 class="font-normal text-md truncate pb-2 pl-2">Latest Conversations</h1>
        <div class="flex items-center space-x-2 pl-2">
          <div class="rounded-full h-2 w-2 bg-indigo-300"></div>
          <p class="truncate text-sm">An open conversation</p>
        </div>
        <div class="flex items-center space-x-2 pl-2">
          <div class="rounded-full h-2 w-2 bg-green-300"></div>
          <p class="truncate text-sm">A resolved conversation</p>
        </div>
        <div class="flex items-center space-x-2 pl-2">
          <div class="rounded-full h-2 w-2 bg-amber-200"></div>
          <p class="truncate text-sm">A prioritized conversation</p>
        </div>
        <div class="flex items-center px-2 py-2 space-x-2">
          <p class="text-sm bg-green-300 leading-3 p-1">Resolved</p>
          <p class="text-sm bg-amber-200 leading-3 p-1">Prioritized</p>
          <p class="text-sm bg-indigo-300 leading-3 p-1">Open</p>
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
        to: ~p"/conversations",
        label: gettext("All"),
        module: ResolvdWeb.ConversationLive
      },
      %{
        to: ~p"/conversations",
        label: gettext("Me"),
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
        label: gettext("Resolved"),
        module: ResolvdWeb.Admin.MailboxLive
      }
    ]
  end

  defp active_conversation?(element, conversation) do
    not is_nil(conversation) and element.id == conversation.id
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

  defp display_info(nil), do: "Unknown"
  defp display_info(info), do: info

  defp message_body(%Message{text_body: body}) when not is_nil(body) do
    raw(String.replace(body, "\r", "<br>"))
    raw(String.replace(body, "\n", "<br>"))
  end

  defp message_body(%Message{html_body: body}) when not is_nil(body) do
    raw(String.replace(body, "\r", "<br>"))
    raw(String.replace(body, "\n", "<br>"))
  end

  defp message_body(_) do
    "~~~"
  end
end