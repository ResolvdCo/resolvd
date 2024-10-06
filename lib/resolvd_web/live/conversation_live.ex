defmodule ResolvdWeb.ConversationLive do
  use ResolvdWeb, :live_view

  alias Resolvd.Mailboxes
  alias Resolvd.Conversations
  alias Resolvd.Conversations.Message

  def mount(params, session, socket) do
    {:ok,
     socket
     |> stream(:conversations, Conversations.list_conversations(socket.assigns.current_user))
     |> assign(:mailboxes, Mailboxes.list_mailboxes(socket.assigns.current_user))
     |> assign(:conversation, nil)
    |> assign(:first_message, nil)}
  end

  def handle_params(%{"id" => conversation_id}, uri, socket) do
    conversation = Conversations.get_conversation!(socket.assigns.current_user, conversation_id)
    messages = Conversations.list_messages_for_conversation(conversation)

    {:noreply,
     socket
     |> assign(:conversation, conversation)
     |> assign(:first_message, hd(messages))
     |> assign(:message, %Message{})
     |> stream(:messages, tl(messages))}
  end

  def handle_params(unsigned_params, uri, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex h-screen">
      <div
        id="conversations"
        phx-update="stream"
        class="flex flex-col space-y-4 overflow-y-scroll w-1/3 divide-y divide-gray-200"
      >
        <.link
          :for={{dom_id, conversation} <- @streams.conversations}
          id={dom_id}
          navigate={~p"/conversations/#{conversation.id}"}
          class="flex justify-between p-2"
        >
          <div>
            <h3 class="text-lg font-medium"><%= conversation.subject %></h3>
            <p><%= conversation.customer.name %></p>
          </div>
          <div>
            <%= conversation.inserted_at
            |> Timex.format("{relative}", :relative)
            |> elem(1) %>
          </div>
        </.link>
      </div>
      <div class="bg-blue-100 w-full">
        <div :if={@conversation} class="">
          <div class="border-b border-t border-gray-200 bg-white shadow-sm sm:rounded-lg sm:border">
            <h3 class="sr-only">Order placed on <time datetime="2021-07-06">Jul 6, 2021</time></h3>

            <div class="flex justify-between border-b border-gray-200 bg-gray-50 p-4">
              <div class="flex space-x-4 items-center">
                <div class="inline-flex h-10 w-10 items-center justify-center rounded-full bg-gray-500">
                  <span class="font-medium leading-none text-white">
                    <%= if @first_message.user do %>
                      <%= Resolvd.Customers.initials(@first_message.user) %>
                    <% else %>
                      <%= Resolvd.Customers.initials(@first_message.customer) %>
                    <% end %>
                  </span>
                </div>
                <div>
                  <h2 class="font-medium text-gray-900"><%= @conversation.subject %></h2>
                  <p class="mt-1 text-gray-500">
                    Opened by
                    <%= if @first_message.user do %>
                      <%= @first_message.user.name %>
                    <% else %>
                      <.link navigate={~p"/customers/#{@first_message.customer.id}"} class="underline">
                        <%= @first_message.customer.name %>
                      </.link>
                    <% end %>
                    <%= @conversation.inserted_at
                    |> Timex.format("{relative}", :relative)
                    |> elem(1) %>
                  </p>
                </div>
              </div>

              <div class="relative flex justify-end lg:hidden">
                <div class="flex items-center">
                  <button
                    type="button"
                    class="-m-2 flex items-center p-2 text-gray-400 hover:text-gray-500"
                    id="menu-0-button"
                    aria-expanded="false"
                    aria-haspopup="true"
                  >
                    <span class="sr-only">Options for order WU88191111</span>
                    <svg
                      class="h-6 w-6"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M12 6.75a.75.75 0 110-1.5.75.75 0 010 1.5zM12 12.75a.75.75 0 110-1.5.75.75 0 010 1.5zM12 18.75a.75.75 0 110-1.5.75.75 0 010 1.5z"
                      />
                    </svg>
                  </button>
                </div>
                <!--
                  Dropdown menu, show/hide based on menu state.

                  Entering: "transition ease-out duration-100"
                    From: "transform opacity-0 scale-95"
                    To: "transform opacity-100 scale-100"
                  Leaving: "transition ease-in duration-75"
                    From: "transform opacity-100 scale-100"
                    To: "transform opacity-0 scale-95"
                -->
                <div
                  class="absolute right-0 z-10 mt-2 w-40 origin-bottom-right rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none"
                  role="menu"
                  aria-orientation="vertical"
                  aria-labelledby="menu-0-button"
                  tabindex="-1"
                >
                  <div class="py-1" role="none">
                    <!-- Active: "bg-gray-100 text-gray-900", Not Active: "text-gray-700" -->
                    <a
                      href="#"
                      class="block px-4 py-2 text-sm text-gray-700"
                      role="menuitem"
                      tabindex="-1"
                      id="menu-0-item-0"
                    >
                      View
                    </a>
                    <a
                      href="#"
                      class="block px-4 py-2 text-sm text-gray-700"
                      role="menuitem"
                      tabindex="-1"
                      id="menu-0-item-1"
                    >
                      Invoice
                    </a>
                  </div>
                </div>
              </div>

              <div class="hidden lg:col-span-2 lg:flex lg:items-center lg:justify-end lg:space-x-4">
                <button
                  type="button"
                  class="bg-gray-200 relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-600 focus:ring-offset-2"
                  role="switch"
                  aria-checked="false"
                >
                  <span class="sr-only">Use setting</span>
                  <!-- Enabled: "translate-x-5", Not Enabled: "translate-x-0" -->
                  <span class="translate-x-0 pointer-events-none relative inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out">
                    <!-- Enabled: "opacity-0 duration-100 ease-out", Not Enabled: "opacity-100 duration-200 ease-in" -->
                    <span
                      class="opacity-100 duration-200 ease-in absolute inset-0 flex h-full w-full items-center justify-center transition-opacity"
                      aria-hidden="true"
                    >
                      <.icon name="hero-flag" class="w-3 h-3" />
                    </span>
                    <!-- Enabled: "opacity-100 duration-200 ease-in", Not Enabled: "opacity-0 duration-100 ease-out" -->
                    <span
                      class="opacity-0 duration-100 ease-out absolute inset-0 flex h-full w-full items-center justify-center transition-opacity"
                      aria-hidden="true"
                    >
                      <svg class="h-3 w-3 text-indigo-600" fill="currentColor" viewBox="0 0 12 12">
                        <path d="M3.707 5.293a1 1 0 00-1.414 1.414l1.414-1.414zM5 8l-.707.707a1 1 0 001.414 0L5 8zm4.707-3.293a1 1 0 00-1.414-1.414l1.414 1.414zm-7.414 2l2 2 1.414-1.414-2-2-1.414 1.414zm3.414 2l4-4-1.414-1.414-4 4 1.414 1.414z" />
                      </svg>
                    </span>
                  </span>
                </button>
                <.dropdown>
                  <:item
                    :for={mailbox <- @mailboxes}
                    label={mailbox.name}
                    checked={@conversation.mailbox_id == mailbox.id}
                  >
                    <%= mailbox.name %>
                  </:item>
                </.dropdown>
                <a
                  :if={false}
                  href="#"
                  class="flex items-center justify-center rounded-md border border-gray-300 bg-white px-2.5 py-2 text-sm font-medium text-gray-700 shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
                >
                  <span>View Order</span>
                  <span class="sr-only">WU88191111</span>
                </a>
                <a
                  :if={false}
                  href="#"
                  class="flex items-center justify-center rounded-md border border-gray-300 bg-white px-2.5 py-2 text-sm font-medium text-gray-700 shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
                >
                  <span>View Invoice</span>
                  <span class="sr-only">for order WU88191111</span>
                </a>
              </div>
            </div>
            <div class="relative divide-y divide-gray-200">
              <div class="p-4 sm:p-6">
                <div class="flex items-center sm:items-start">
                  <div
                    :if={false}
                    class="h-20 w-20 flex-shrink-0 overflow-hidden rounded-lg bg-gray-200 sm:h-40 sm:w-40"
                  >
                    <img
                      src="https://tailwindui.com/img/ecommerce-images/order-history-page-03-product-01.jpg"
                      alt="Moss green canvas compact backpack with double top zipper, zipper front pouch, and matching carry handle and backpack straps."
                      class="h-full w-full object-cover object-center"
                    />
                  </div>
                  <div class="flex-1 ">
                    <div :if={false} class="font-medium text-gray-900 sm:flex sm:justify-between">
                      <h5>Micro Backpack</h5>
                      <p class="mt-2 sm:mt-0">$70.00</p>
                    </div>
                    <div class="prose">
                      <%= message_body(@first_message) %>
                    </div>
                  </div>
                </div>
              </div>
              <div id="messages" phx-update="stream" class="divide-y divide-gray-200">
                <div :for={{dom_id, message} <- @streams.messages} id={dom_id} class="p-4 sm:p-6">
                  <div class="flex space-x-4 items-center mb-2">
                    <img
                      class="flex items-center justify-center h-10 w-10 rounded-full flex-shrink-0"
                      src={
                        gravatar_avatar(if(message.user, do: message.user, else: message.customer))
                      }
                    />
                    <div>
                      <h2 class="font-medium text-gray-900">
                        <%= if message.user do %>
                          <%= message.user.name %>
                        <% else %>
                          <%= message.customer.name %>
                        <% end %>
                        <span
                          :if={message.user}
                          class="inline-flex items-center rounded-md bg-red-50 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/10"
                        >
                          Staff
                        </span>
                      </h2>
                      <p class="mt-1 text-gray-500">
                        Sent <%= message.inserted_at
                        |> Timex.format("{relative}", :relative)
                        |> elem(1) %>
                      </p>
                    </div>
                  </div>
                  <div class="flex items-center sm:items-start">
                    <div
                      :if={false}
                      class="h-20 w-20 flex-shrink-0 overflow-hidden rounded-lg bg-gray-200 sm:h-40 sm:w-40"
                    >
                      <img
                        src="https://tailwindui.com/img/ecommerce-images/order-history-page-03-product-01.jpg"
                        alt="Moss green canvas compact backpack with double top zipper, zipper front pouch, and matching carry handle and backpack straps."
                        class="h-full w-full object-cover object-center"
                      />
                    </div>
                    <div class="flex-1 ">
                      <div :if={false} class="font-medium text-gray-900 sm:flex sm:justify-between">
                        <h5>Micro Backpack</h5>
                        <p class="mt-2 sm:mt-0">$70.00</p>
                      </div>
                      <div class="prose">
                        <%= message_body(message) %>
                      </div>
                    </div>
                  </div>

                  <div class="mt-6 sm:flex sm:justify-between">
                    <div class="flex items-center">
                      <.icon name="hero-inbox-arrow-down" class="h-5 w-5 text-gray-500" />
                      <p class="ml-2 text-sm font-medium text-gray-500">
                        Delivered <%= message.inserted_at
                        |> Timex.format("{relative}", :relative)
                        |> elem(1) %>
                      </p>
                    </div>

                    <div
                      :if={false}
                      class="mt-6 flex items-center space-x-4 divide-x divide-gray-200 border-t border-gray-200 pt-4 text-sm font-medium sm:ml-4 sm:mt-0 sm:border-none sm:pt-0"
                    >
                      <div class="flex flex-1 justify-center">
                        <a href="#" class="whitespace-nowrap text-indigo-600 hover:text-indigo-500">
                          View product
                        </a>
                      </div>
                      <div class="flex flex-1 justify-center pl-4">
                        <a href="#" class="whitespace-nowrap text-indigo-600 hover:text-indigo-500">
                          Buy again
                        </a>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="sticky bottom-1 bg-white shadow-inner border-b border-black"></div>
              <!-- More products... -->
            </div>
          </div>
          <!-- More orders... -->
        </div>
      </div>
    </div>
    """
  end

  defp message_body(%Message{html_body: html_body, text_body: text_body}) do
    body = html_body || text_body || ""

    body
    |> String.replace("\n", "<br>")
    # |> String.replace(~r/<br( \/)?>(\s|[\r\n])?<br( \/)?>/m, "<br>")
    # # |> String.replace(~r/<br( \/)?>(\s|[\r\n])?<br( \/)?>/m, "<br>")
    # |> dbg()
    |> raw()
  end

  defp message_body(_) do
    "~~~"
  end

  defp gravatar_avatar(%{email: email}) do
    hash = :crypto.hash(:md5, email) |> Base.encode16(case: :lower)
    "https://www.gravatar.com/avatar/#{hash}"
  end

  defp gravatar_avatar(email) do
    hash = :crypto.hash(:md5, email) |> Base.encode16(case: :lower)
    "https://www.gravatar.com/avatar/#{hash}"
  end
end
