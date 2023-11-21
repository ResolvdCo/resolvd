defmodule ResolvdWeb.Utils do
  use ResolvdWeb, :html

  alias Resolvd.Customers.Customer
  alias Resolvd.Conversations.Conversation

  attr :email, :string, required: true
  attr :class, :string, default: nil

  def profile_picture(assigns) do
    ~H"""
    <img class={["object-cover w-10 h-10 rounded-full", @class]} src={gravatar_avatar(@email)} alt="" />
    """
  end

  attr :class, :any, default: nil
  attr :label, :string, required: true
  attr :position, :string, default: "right", values: ~w(right left top bottom)
  slot :inner_block, required: true

  def tooltip(assigns) do
    ~H"""
    <div class="relative group flex items-center justify-center">
      <%= render_slot(@inner_block) %>

      <span class={[
        "invisible opacity-0 group-hover:opacity-100 group-hover:visible group-hover:delay-500 group-hover:hover:delay-0 group-hover:hover:opacity-0 group-hover:hover:invisible transition-opacity absolute whitespace-nowrap bg-gray-600 text-white text-center rounded-md px-2 py-1 z-30 ",
        "after:absolute after:border-[5px] after:border-transparent",
        case @position do
          "right" ->
            "left-[120%] after:top-1/2 after:right-full after:-mt-[5px] after:border-r-gray-600"

          "left" ->
            "right-[120%] after:top-1/2 after:left-full after:-mt-[5px] after:border-l-gray-600"

          "top" ->
            "bottom-[125%] after:right-1/2 after:top-full after:-mr-[5px] after:border-t-gray-600"

          "bottom" ->
            "top-[125%] after:right-1/2 after:bottom-full after:-mr-[5px] after:border-b-gray-600"
        end,
        @class
      ]}>
        <%= @label %>
      </span>
    </div>
    """
  end

  attr :conversation, :map, required: true
  attr :rest, :global

  def conversation_status(assigns) do
    ~H"""
    <span
      class={[
        "inline-flex items-center gap-1 rounded-full px-2 py-1 text-xs font-semibold",
        @conversation |> conversation_status_colors() |> elem(0)
      ]}
      {@rest}
    >
      <span class={[
        "h-1.5 w-1.5 rounded-full",
        @conversation |> conversation_status_colors() |> elem(1)
      ]}>
      </span>
      <%= @conversation |> conversation_status_colors() |> elem(2) %>
    </span>
    """
  end

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :options, :list, required: true
  attr :value, :any
  attr :rest, :global
  slot :inner_block, required: true

  def select(assigns) do
    ~H"""
    <div class="relative">
      <select id={@id} name={@name} class="pl-8 text-sm rounded-lg border-white shadow" {@rest}>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>

      <span class="absolute top-2 left-2">
        <%= render_slot(@inner_block) %>
      </span>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :checked, :boolean, required: true
  attr :class, :string, required: true
  attr :rest, :global
  slot :inner_block, required: true

  def checkbox(assigns) do
    ~H"""
    <div>
      <input type="hidden" name={@name} value="false" />
      <input
        type="checkbox"
        id={@id}
        name={@name}
        value="true"
        class="peer hidden"
        checked={@checked}
        {@rest}
      />
      <label
        for={@id}
        class={[
          "flex items-center justify-center bg-gray-100 text-gray-700 h-10 w-10 rounded-full hover:cursor-pointer",
          @class
        ]}
      >
        <%= render_slot(@inner_block) %>
      </label>
    </div>
    """
  end

  attr :conversation, :map, required: true
  attr :current_user, :map, required: true
  attr :class, :string, default: nil

  def assigned_user(assigns) do
    ~H"""
    <span class="flex gap-1 whitespace-nowrap">
      <.user_icon user_id={@conversation.user_id} current_user={@current_user} class={@class} />

      <%= if @conversation.user_id, do: @conversation.user.name, else: "Not assigned" %>
    </span>
    """
  end

  attr :prioritized?, :boolean, default: false
  attr :rest, :global
  attr :class, :string, default: nil

  def prioritize_icon(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      stroke-width="1.5"
      stroke="currentColor"
      class={[
        "w-6 h-6",
        if(@prioritized?, do: "text-amber-600 fill-amber-100", else: "text-gray-500"),
        @class
      ]}
      {@rest}
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M11.48 3.499a.562.562 0 011.04 0l2.125 5.111a.563.563 0 00.475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 00-.182.557l1.285 5.385a.562.562 0 01-.84.61l-4.725-2.885a.563.563 0 00-.586 0L6.982 20.54a.562.562 0 01-.84-.61l1.285-5.386a.562.562 0 00-.182-.557l-4.204-3.602a.563.563 0 01.321-.988l5.518-.442a.563.563 0 00.475-.345L11.48 3.5z"
      />
    </svg>
    """
  end

  attr :resolved?, :boolean, default: false
  attr :rest, :global
  attr :class, :string, default: nil

  def resolved_icon(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      stroke-width="1.5"
      stroke="currentColor"
      class={[
        "w-6 h-6",
        if(@resolved?, do: "text-green-600 fill-green-100", else: "text-gray-500"),
        @class
      ]}
      {@rest}
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
      />
    </svg>
    """
  end

  def delete_icon(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      stroke-width="1.5"
      stroke="currentColor"
      class="w-6 h-6 text-gray-500"
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0"
      />
    </svg>
    """
  end

  attr :user_id, :string, required: true
  attr :current_user, :map, required: true
  attr :class, :string, default: nil

  def user_icon(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      stroke-width="1.5"
      stroke="currentColor"
      aria-hidden="true"
      class={[
        "h-5 w-5",
        case @user_id do
          nil -> nil
          id when id == @current_user.id -> "text-blue-500 fill-blue-500"
          _ -> "text-gray-700 fill-gray-700"
        end,
        @class
      ]}
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z"
      />
    </svg>
    """
  end

  attr :class, :string, default: nil

  def envelope_icon(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      stroke-width="1.5"
      stroke="currentColor"
      aria-hidden="true"
      class={["h-5 w-5", @class]}
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M21.75 6.75v10.5a2.25 2.25 0 01-2.25 2.25h-15a2.25 2.25 0 01-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25m19.5 0v.243a2.25 2.25 0 01-1.07 1.916l-7.5 4.615a2.25 2.25 0 01-2.36 0L3.32 8.91a2.25 2.25 0 01-1.07-1.916V6.75"
      />
    </svg>
    """
  end

  def display_name(%Customer{} = customer) do
    cond do
      # Name can contain non-ASCII characters
      not is_nil(customer.name) -> customer.name
      not is_nil(customer.email) -> customer.email
      not is_nil(customer.phone) -> customer.phone
      true -> "Customer"
    end
  end

  def display_info(nil), do: "Unknown"
  def display_info(info), do: info

  def make_options_for_select(options) do
    options |> Enum.map(fn %{id: id, name: name} -> {name, id} end)
  end

  defp conversation_status_colors(%Conversation{} = conversation) do
    cond do
      conversation.is_resolved ->
        {"bg-green-50 text-green-600", "bg-green-600", "Resolved"}

      conversation.is_prioritized ->
        {"bg-amber-100 text-amber-600", "bg-amber-600", "Prioritized"}

      true ->
        {"bg-indigo-50 text-indigo-600", "bg-indigo-600", "Unresolved"}
    end
  end

  defp gravatar_avatar(email) do
    hash = :crypto.hash(:md5, email) |> Base.encode16(case: :lower)
    "https://www.gravatar.com/avatar/#{hash}"
  end
end
