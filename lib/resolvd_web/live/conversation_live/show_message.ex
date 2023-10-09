defmodule ResolvdWeb.ConversationLive.ShowMessage do
  use ResolvdWeb, :live_component

  alias Resolvd.Conversations.Message

  @impl true
  def render(assigns) do
    ~H"""
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
    """
  end

  defp gravatar_avatar(email) do
    hash = :crypto.hash(:md5, email) |> Base.encode16(case: :lower)
    "https://www.gravatar.com/avatar/#{hash}"
  end

  defp message_body(%Message{html_body: body}) when not is_nil(body) do
    raw(String.replace(body, "\r", "<br>"))
  end

  defp message_body(%Message{text_body: body}) when not is_nil(body) do
    raw(String.replace(body, "\r", "<br>"))
  end

  defp message_body(_) do
    "~~~"
  end
end
