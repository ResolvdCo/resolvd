defmodule ResolvdWeb.ConversationLive.Show do
  alias Resolvd.Mailboxes
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
    messages = Conversations.list_messages_for_conversation(conversation)

    Phoenix.PubSub.subscribe(Resolvd.PubSub, id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:mailboxes, Mailboxes.list_mailboxes(socket.assigns.current_user))
     |> assign(:conversation, conversation)
     |> assign(:message, %Message{})
     |> assign(:first_message, hd(messages))
     |> stream(:messages, tl(messages))}

    # |> stream(:messages, conversation.messages)}
  end

  def render(assigns) do
    ~H"""
    <div class="">
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
                  src={gravatar_avatar(if(message.user, do: message.user, else: message.customer))}
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
          <div class="sticky bottom-1 bg-white shadow-inner border-b border-black">
            <.live_component
              module={ResolvdWeb.ConversationLive.MessageComponent}
              id={:new}
              message={@message}
              action={:new}
              conversation={@conversation}
              current_user={@current_user}
            />
          </div>
          <!-- More products... -->
        </div>
      </div>
      <!-- More orders... -->
    </div>
    """
  end

  defp old_stuff(assigns) do
    ~H"""
    <%!--
        <div :if={false} class="mb-8">
      <div class="flex space-x-2">
        <span class="inline-flex h-10 w-10 items-center justify-center rounded-full bg-gray-500">
          <span class="font-medium leading-none text-white">
            <%= if @first_message.user do %>
              <%= Resolvd.Customers.initials(@first_message.user) %>
            <% else %>
              <%= Resolvd.Customers.initials(@first_message.customer) %>
            <% end %>
          </span>
        </span>
        <div>
          <h3 :if={@first_message.user}><%= @first_message.user.name %></h3>
          <h3 :if={@first_message.customer}><%= @first_message.customer.name %></h3>

          <div>
            <%= @first_message.inserted_at
            |> Timex.format("{relative}", :relative)
            |> elem(1) %>
          </div>
        </div>
      </div>
      <div class="prose">
        <%= message_body(@first_message) %>
      </div>
    </div>

    <div class="lg:flex lg:items-center lg:justify-between">
      <div class="min-w-0 flex-1">
        <h2 class="text-2xl font-bold leading-7 text-gray-900 sm:truncate sm:text-3xl sm:tracking-tight">
          <%= @conversation.subject %>
        </h2>
        <div class="mt-1 flex flex-col sm:mt-0 sm:flex-row sm:flex-wrap sm:space-x-6">
          <div class="mt-2 flex items-center text-sm text-gray-500">
            <div class="flex items-center">
              <!-- Enabled: "bg-indigo-600", Not Enabled: "bg-gray-200" -->
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
              <span class="ml-3 text-sm" id="annual-billing-label">
                <span class="font-medium text-gray-900">High Priority</span>
              </span>
            </div>
          </div>
          <div class="mt-2 flex items-center text-sm text-gray-500">
            <.dropdown>
              <:item
                :for={mailbox <- @mailboxes}
                label={mailbox.name}
                checked={@conversation.mailbox_id == mailbox.id}
              >
                <%= mailbox.name %>
              </:item>
            </.dropdown>
          </div>

          <div class="mt-2 flex items-center text-sm text-gray-500">
            <svg
              class="mr-1.5 h-5 w-5 flex-shrink-0 text-gray-400"
              viewBox="0 0 20 20"
              fill="currentColor"
              aria-hidden="true"
            >
              <path
                fill-rule="evenodd"
                d="M5.75 2a.75.75 0 01.75.75V4h7V2.75a.75.75 0 011.5 0V4h.25A2.75 2.75 0 0118 6.75v8.5A2.75 2.75 0 0115.25 18H4.75A2.75 2.75 0 012 15.25v-8.5A2.75 2.75 0 014.75 4H5V2.75A.75.75 0 015.75 2zm-1 5.5c-.69 0-1.25.56-1.25 1.25v6.5c0 .69.56 1.25 1.25 1.25h10.5c.69 0 1.25-.56 1.25-1.25v-6.5c0-.69-.56-1.25-1.25-1.25H4.75z"
                clip-rule="evenodd"
              />
            </svg>
            Opened on <%= Calendar.strftime(@conversation.inserted_at, "%A, %B %d %Y @ %I:%M %p") %>
          </div>
        </div>
      </div>
      <div class="mt-5 flex lg:ml-4 lg:mt-0">
        <span class="hidden sm:block">
          <.link patch={~p"/conversations/#{@conversation}/show/edit"} phx-click={JS.push_focus()}>
            <.button class="flex">
              <.icon name="hero-pencil" class="mr-2 text-gray-400" /> Edit Conversation
            </.button>
          </.link>
        </span>

        <span class="ml-3 hidden sm:block">
          <button
            type="button"
            class="inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
          >
            <svg
              class="-ml-0.5 mr-1.5 h-5 w-5 text-gray-400"
              viewBox="0 0 20 20"
              fill="currentColor"
              aria-hidden="true"
            >
              <path d="M12.232 4.232a2.5 2.5 0 013.536 3.536l-1.225 1.224a.75.75 0 001.061 1.06l1.224-1.224a4 4 0 00-5.656-5.656l-3 3a4 4 0 00.225 5.865.75.75 0 00.977-1.138 2.5 2.5 0 01-.142-3.667l3-3z" />
              <path d="M11.603 7.963a.75.75 0 00-.977 1.138 2.5 2.5 0 01.142 3.667l-3 3a2.5 2.5 0 01-3.536-3.536l1.225-1.224a.75.75 0 00-1.061-1.06l-1.224 1.224a4 4 0 105.656 5.656l3-3a4 4 0 00-.225-5.865z" />
            </svg>
            View
          </button>
        </span>

        <span class="sm:ml-3">
          <button
            type="button"
            class="inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
          >
            <svg
              class="-ml-0.5 mr-1.5 h-5 w-5"
              viewBox="0 0 20 20"
              fill="currentColor"
              aria-hidden="true"
            >
              <path
                fill-rule="evenodd"
                d="M16.704 4.153a.75.75 0 01.143 1.052l-8 10.5a.75.75 0 01-1.127.075l-4.5-4.5a.75.75 0 011.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 011.05-.143z"
                clip-rule="evenodd"
              />
            </svg>
            Publish
          </button>
        </span>
        <!-- Dropdown -->
        <div class="relative ml-3 sm:hidden">
          <button
            type="button"
            class="inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:ring-gray-400"
            id="mobile-menu-button"
            aria-expanded="false"
            aria-haspopup="true"
          >
            More
            <svg
              class="-mr-1 ml-1.5 h-5 w-5 text-gray-400"
              viewBox="0 0 20 20"
              fill="currentColor"
              aria-hidden="true"
            >
              <path
                fill-rule="evenodd"
                d="M5.23 7.21a.75.75 0 011.06.02L10 11.168l3.71-3.938a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z"
                clip-rule="evenodd"
              />
            </svg>
          </button>
          <!--
        Dropdown menu, show/hide based on menu state.

        Entering: "transition ease-out duration-200"
          From: "transform opacity-0 scale-95"
          To: "transform opacity-100 scale-100"
        Leaving: "transition ease-in duration-75"
          From: "transform opacity-100 scale-100"
          To: "transform opacity-0 scale-95"
      -->
          <div
            class="absolute right-0 z-10 -mr-1 mt-2 w-48 origin-top-right rounded-md bg-white py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none"
            role="menu"
            aria-orientation="vertical"
            aria-labelledby="mobile-menu-button"
            tabindex="-1"
          >
            <!-- Active: "bg-gray-100", Not Active: "" -->
            <a
              href="#"
              class="block px-4 py-2 text-sm text-gray-700"
              role="menuitem"
              tabindex="-1"
              id="mobile-menu-item-0"
            >
              Edit
            </a>
            <a
              href="#"
              class="block px-4 py-2 text-sm text-gray-700"
              role="menuitem"
              tabindex="-1"
              id="mobile-menu-item-1"
            >
              View
            </a>
          </div>
        </div>
      </div>
    </div>

    <.card>
      <.header><%= @conversation.subject %></.header>
      <div class="prose">
        <%= message_body(@first_message) %>
      </div>
    </.card>
    <.header>
      <%= @conversation.subject %>
      <:subtitle>This is a conversation record from your database.</:subtitle>
      <:actions>
        <.link patch={~p"/conversations/#{@conversation}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit conversation</.button>
        </.link>
      </:actions>
    </.header>

    <div>
      <div class="flex h-full antialiased text-gray-800">
        <div class="flex flex-row h-full w-full overflow-x-hidden">
          <div class="flex flex-col flex-auto h-full p-6">
            <div class="flex flex-col flex-auto flex-shrink-0 rounded-2xl h-full p-4">
              <div class="flex flex-col h-full overflow-x-auto mb-4">
                <div class="flex flex-col h-full">
                  <div class="grid grid-cols-12 gap-y-2" phx-update="stream" id="messages">
                    <%= for {dom_id, message} <- @streams.messages do %>
                      <%= if is_nil(message.customer_id) do %>
                        <div class="col-start-6 col-end-13 p-3 rounded-lg" id={dom_id}>
                          <div class="flex items-center justify-start flex-row-reverse">
                            <img
                              class="flex items-center justify-center h-10 w-10 rounded-full bg-indigo-500 flex-shrink-0"
                              src={gravatar_avatar(message.user.email)}
                            />
                            <div class="relative mr-3 text-sm bg-indigo-100 py-2 px-4 shadow rounded-xl space-y-2">
                              <div class="flex w-full justify-between space-x-4">
                                <div class="text-sm text-gray-900 font-medium">
                                  <%= if is_nil(message.user.name),
                                    do: message.user.email,
                                    else: message.user.name %>
                                </div>
                                <div class="tex-xs text-gray-500">
                                  <%= message.inserted_at
                                  |> Timex.format("{relative}", :relative)
                                  |> elem(1) %>
                                </div>
                              </div>
                              <div><%= message_body(message) %></div>
                            </div>
                          </div>
                        </div>
                      <% else %>
                        <div class="col-start-1 col-end-8 p-3 rounded-lg" id={dom_id}>
                          <div class="flex flex-row items-center">
                            <img
                              class="flex items-center justify-center h-10 w-10 rounded-full bg-indigo-500 flex-shrink-0"
                              src={gravatar_avatar(message.customer.email)}
                            />
                            <div class="relative ml-3 text-sm bg-white py-2 px-4 shadow rounded-xl space-y-2">
                              <div class="flex w-full justify-between space-x-4">
                                <div class="text-sm text-gray-900 font-medium">
                                  <%= if is_nil(message.customer.name),
                                    do: message.customer.email,
                                    else: message.customer.name %>
                                </div>
                                <div class="tex-xs text-gray-500">
                                  <%= message.inserted_at
                                  |> Timex.format("{relative}", :relative)
                                  |> elem(1) %>
                                </div>
                              </div>
                              <div><%= message_body(message) %></div>
                            </div>
                          </div>
                        </div>
                      <% end %>
                    <% end %>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <.live_component
      module={ResolvdWeb.ConversationLive.MessageComponent}
      id={:new}
      message={@message}
      action={:new}
      conversation={@conversation}
      current_user={@current_user}
    />

    <.back navigate={~p"/conversations"}>Back to conversations</.back>

    <.modal
      :if={@live_action == :edit}
      id="conversation-modal"
      show
      on_cancel={JS.patch(~p"/conversations/#{@conversation}")}
    >
      <.live_component
        module={ResolvdWeb.ConversationLive.ConversationComponent}
        id={@conversation.id}
        title={@page_title}
        action={@live_action}
        conversation={@conversation}
        patch={~p"/conversations/#{@conversation}"}
        current_user={@current_user}
      />
    </.modal>
    --%>
    """
  end

  # defp responder_avatar(%{user: user, customer: customer}) do
  #   ~H"""
  #   <img
  #     class="flex items-center justify-center h-10 w-10 rounded-full flex-shrink-0"
  #     src={gravatar_avatar(if(user, do: user, else: customer))}
  #   />
  #   """
  # end

  @impl true
  def handle_info(
        {ResolvdWeb.ConversationLive.MessageComponent, {:saved, message, conversation}},
        socket
      ) do
    {:noreply, stream_insert(socket, :messages, message)}
  end

  defp page_title(:show), do: "Show Conversation"
  defp page_title(:edit), do: "Edit Conversation"

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
