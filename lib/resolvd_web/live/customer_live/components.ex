defmodule ResolvdWeb.CustomerLive.Components do
  use ResolvdWeb, :html

  alias ResolvdWeb.Utils
  alias ResolvdWeb.Router.Helpers

  attr :customers, :any, required: true
  attr :customer, :map, required: true
  attr :socket, :any, required: true
  attr :live_action, :atom, required: true

  def customer_list(assigns) do
    ~H"""
    <div class="h-full overflow-hidden relative shadow-inner">
      <div class="flex flex-col h-full w-full overflow-y-auto " id="customers" phx-update="stream">
        <%= for {dom_id, customer} <- @customers do %>
          <.link
            id={dom_id}
            patch={Helpers.customer_index_path(@socket, @live_action, id: customer.id)}
            class={[
              "flex flex-row items-center px-4 py-4 border-l-2 from-red-100 to-transparent",
              if(active_customer?(customer, @customer),
                do: "bg-gradient-to-r border-x-red-500",
                else: "hover:bg-gradient-to-r hover:border-x-red-100"
              )
            ]}
          >
            <Utils.profile_picture email={customer.email} class="h-10 w-10" />
            <div class="flex flex-col justify-between h-10 w-72 ml-2">
              <div class="flex justify-between items-center space-x-5">
                <h1 class={[
                  "text-sm font-medium truncate",
                  if(active_customer?(customer, @customer),
                    do: "text-gray-800",
                    else: "text-gray-700"
                  )
                ]}>
                  <%= Utils.display_name(customer) %>
                </h1>

                <span class="text-xs whitespace-nowrap text-gray-500">
                  <%= customer.updated_at
                  |> Timex.format("{relative}", :relative)
                  |> elem(1) %>
                </span>
              </div>

              <div class="flex justify-between items-center space-x-5">
                <p class={[
                  "text-xs truncate w-64",
                  if(active_customer?(customer, @customer),
                    do: "text-gray-700",
                    else: "text-gray-600"
                  )
                ]}>
                  <span class="flex items-center space-x-1">
                    <.icon name="hero-envelope" class="h-3 w-3" />
                    <span><%= Utils.display_info(customer.email) %></span>
                  </span>
                </p>
              </div>
            </div>
          </.link>
        <% end %>
      </div>
    </div>
    """
  end

  attr :customer, :map, required: true

  def header(assigns) do
    ~H"""
    <div class="z-30 flex items-center py-4 px-6 rounded-2xl shadow-md justify-between space-x-5">
      <div class="flex overflow-hidden space-x-2 items-center">
        <Utils.profile_picture email={@customer.email} />
        <h1 class="font-semibold text-2xl text-gray-600 truncate" id="customer-name-title">
          <%= Utils.display_name(@customer) %>
        </h1>
        <span class="flex items-center gap-x-1 pl-10">
          <.icon name="hero-envelope-solid" class="h-4 w-4 bg-gray-500" />
          <span class="font-medium text-sm text-gray-500">
            <%= Utils.display_info(@customer.email) %>
          </span>
        </span>

        <span class="flex items-center gap-x-1 pl-5">
          <.icon name="hero-phone-solid" class="h-4 w-4 bg-gray-500" />
          <span class="font-medium text-sm text-gray-500">
            <%= Utils.display_info(@customer.phone) %>
          </span>
        </span>
      </div>
      <button class="px-4 py-2 bg-red-500 text-white rounded-3xl hover:bg-red-400 active:text-red-600 active:bg-red-200">
        <.icon name="hero-chat-bubble-left" /> New Conversation
      </button>
    </div>
    """
  end

  attr :conversations, :any, required: true
  attr :current_user, :map, required: true
  attr :user_options, :list, required: true
  attr :mailbox_options, :list, required: true

  def conversation_list(assigns) do
    ~H"""
    <div class="overflow-scroll rounded-lg border border-gray-200 shadow-md m-5">
      <table class="w-full border-collapse bg-white text-left text-sm text-gray-500">
        <thead class="bg-gray-100">
          <tr>
            <th
              :for={heading <- ["Subject", "Last Updated", "Status", "Assigned", "Mailbox", ""]}
              scope="col"
              class="px-6 py-4 font-medium text-gray-900 whitespace-nowrap"
            >
              <%= heading %>
            </th>
          </tr>
        </thead>

        <tbody class="divide-y divide-gray-100 h-full" phx-update="stream" id="customer-conversations">
          <%= for {dom_id, conversation} <- @conversations do %>
            <tr class="group/row hover:bg-gray-50" id={dom_id}>
              <td
                class="px-6 py-2 text-gray-700 text-sm font-medium hover:cursor-pointer"
                phx-click={
                  JS.patch(~p"/customers?id=#{conversation.customer}&conversation_id=#{conversation}")
                }
              >
                <.link patch={
                  ~p"/customers?id=#{conversation.customer}&conversation_id=#{conversation}"
                }>
                  <%= Resolvd.Mailboxes.parse_mime_encoded_word(conversation.subject) %>
                </.link>
              </td>
              <td
                class="px-6 py-2 hover:cursor-pointer"
                phx-click={
                  JS.patch(~p"/customers?id=#{conversation.customer}&conversation_id=#{conversation}")
                }
              >
                <.link patch={
                  ~p"/customers?id=#{conversation.customer}&conversation_id=#{conversation}"
                }>
                  <%= conversation.updated_at
                  |> Timex.format("{relative}", :relative)
                  |> elem(1) %>
                </.link>
              </td>
              <td
                class="px-6 py-2 hover:cursor-pointer"
                phx-click={
                  JS.patch(~p"/customers?id=#{conversation.customer}&conversation_id=#{conversation}")
                }
              >
                <.link patch={
                  ~p"/customers?id=#{conversation.customer}&conversation_id=#{conversation}"
                }>
                  <span class="hidden" id={"assigned-#{conversation.id}"}>
                    Assigned to: <%= conversation.user_id || "Not assigned" %>
                  </span>

                  <span class="hidden" id={"mailbox-#{conversation.id}"}>
                    Mailbox: <%= conversation.mailbox_id %>
                  </span>

                  <Utils.conversation_status
                    conversation={conversation}
                    id={"status-#{conversation.id}"}
                  />
                </.link>
              </td>
              <td class="px-6 py-2">
                <form>
                  <Utils.select
                    id={"assignee-select-#{conversation.id}"}
                    name={"assignee-#{conversation.id}"}
                    options={@user_options}
                    value={conversation.user_id}
                    phx-change="assignee_changed"
                  >
                    <Utils.user_icon user_id={conversation.user_id} current_user={@current_user} />
                  </Utils.select>
                </form>
              </td>
              <td class="px-6 py-2 whitespace-nowrap">
                <form>
                  <Utils.select
                    id={"mailbox-select-#{conversation.id}"}
                    name={"mailbox-#{conversation.id}"}
                    options={@mailbox_options}
                    value={conversation.mailbox_id}
                    phx-change="mailbox_changed"
                  >
                    <Utils.envelope_icon />
                  </Utils.select>
                </form>
              </td>
              <td class="px-6 py-4">
                <form>
                  <div class="flex justify-end gap-4 items-center">
                    <Utils.tooltip label="Toggle priority" position="left" class="right-[130%]">
                      <Utils.checkbox
                        id={"priority-change-#{conversation.id}"}
                        name={"priority-#{conversation.id}"}
                        checked={conversation.is_prioritized}
                        class="bg-white group-hover/row:bg-gray-50 w-6 h-6"
                        phx-change="priority_changed"
                      >
                        <Utils.prioritize_icon prioritized?={conversation.is_prioritized} />
                      </Utils.checkbox>
                    </Utils.tooltip>

                    <Utils.tooltip label="Toggle resolved" position="left" class="right-[130%]">
                      <Utils.checkbox
                        id={"resolved-change-#{conversation.id}"}
                        name={"resolved-#{conversation.id}"}
                        checked={conversation.is_resolved}
                        class="bg-white group-hover/row:bg-gray-50 w-6 h-6"
                        phx-change="status_changed"
                      >
                        <Utils.resolved_icon resolved?={conversation.is_resolved} />
                      </Utils.checkbox>
                    </Utils.tooltip>

                    <Utils.tooltip label="Delete" position="left" class="right-[130%]">
                      <Utils.checkbox
                        id={"delete-#{conversation.id}"}
                        name={"delete-#{conversation.id}"}
                        checked={false}
                        class="bg-white group-hover/row:bg-gray-50 w-6 h-6"
                        phx-change="delete_changed"
                      >
                        <Utils.delete_icon />
                      </Utils.checkbox>
                    </Utils.tooltip>
                  </div>
                </form>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  defp active_customer?(element, customer) do
    not is_nil(customer) and element.id == customer.id
  end
end
