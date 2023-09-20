defmodule ResolvdWeb.Admin do
  use ResolvdWeb, :html

  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"

  attr :page, :string, default: ""

  slot :inner_block, required: true
  slot :title
  slot :title_actions
  slot :description
  slot :nav

  def page(assigns) do
    ~H"""
    <div class="flex flex-col items-stretch justify-between lg:col-span-9">
      <div class="p-4 md:flex md:items-center md:justify-between">
        <div class="min-w-0 flex-1">
          <h1 class="font-light leading-tight text-4xl mt-0 mb-2">
            Admin
          </h1>
        </div>
      </div>

      <%= render_slot(@nav) || "" %>
      <.tab_nav>
        <:item to={~p"/admin/settings"}>
          <%= gettext("Settings") %>
        </:item>
        <:item to={~p"/admin/billing"}>
          <%= gettext("Billing") %>
        </:item>
        <:item to={~p"/admin/mailboxes"}>
          <%= gettext("Mailboxes") %>
        </:item>
      </.tab_nav>

      <div class="flex-1 mt-[-1px] border-t border-slate-700">
        <%= if live_flash(@flash, :info) do %>
          <p class="alert alert-info" role="alert" phx-click="lv:clear-flash" phx-value-key="info">
            <%= live_flash(@flash, :info) %>
          </p>
        <% end %>
        <%= if live_flash(@flash, :error) do %>
          <p class="alert alert-danger" role="alert" phx-click="lv:clear-flash" phx-value-key="error">
            <%= live_flash(@flash, :error) %>
          </p>
        <% end %>

        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.tab_nav>
        <:item to=~p"/some/link">Some Link</:item>
        <:item to=~p"/another/link">Another Link</:item>
      </.tab_nav>
  """
  slot :item, required: true do
    attr :to, :string, required: true
    attr :active, :boolean
  end

  def tab_nav(assigns) do
    ~H"""
    <div class="z-10">
      <div class="sm:hidden">
        <label for="tabs" class="sr-only">Select a tab</label>
        <!-- Use an "onChange" listener to redirect the user to the selected tab URL. -->
        <select
          id="tabs"
          name="tabs"
          class="block w-full text-black rounded-md border-slate-700 focus:border-indigo-500 focus:ring-indigo-500"
        >
          <option
            :for={item <- @item}
            phx-click={JS.navigate(item.to)}
            selected={Map.get(item, :active, false)}
          >
            <%= render_slot(item) %>
          </option>
        </select>
      </div>
      <div class="hidden sm:block">
        <div class="border-b border-slate-700">
          <nav class="-mb-px flex" aria-label="Tabs">
            <!-- Current: "border-indigo-500 text-indigo-600", Default: "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700" -->
            <!-- border-seafoam text-seafoam -->
            <.link
              :for={item <- @item}
              patch={item.to}
              class={[
                "hover:border-seafoam hover:text-seafoam w-1/4 border-b-2 py-4 px-1 text-center text-sm font-medium",
                if(Map.get(item, :active, false),
                  do: "border-seafoam text-seafoam",
                  else: "border-transparent text-black"
                )
              ]}
            >
              <%= render_slot(item) %>
            </.link>
          </nav>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a form that takes up the full page

  ## Examples

      <.page_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.page_form>
  """
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :title, doc: "The title for the card form"
  slot :subtitle, doc: "The subtitle for the card form"
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def page_form(assigns) do
    ~H"""
    <.form
      :let={f}
      class="h-full flex flex-col items-stretch justify-between"
      for={@for}
      as={@as}
      {@rest}
    >
      <div class="flex-1 py-6 sm:p-6">
        <div>
          <Title.h2><%= render_slot(@title, f) %></Title.h2>
          <p class="text-sm">
            <%= render_slot(@subtitle, f) %>
          </p>
        </div>

        <div class="">
          <%= render_slot(@inner_block, f) %>
        </div>
      </div>
      <div class="bg-slate-800/75 px-4 py-3 text-right sm:px-6 rounded-br-lg">
        <div :for={action <- @actions}>
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :rest, :global, include: ~w(disabled form readonly required)
  slot :inner_block
  slot :fields

  def toggle_block(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      |> assign(field: nil, id: assigns.id || field.id)
      |> assign(:errors, Enum.map(field.errors, &ResolvdWeb.CoreComponents.translate_error(&1)))
      |> assign_new(:name, fn -> field.name end)
      |> assign_new(:value, fn -> field.value end)
      |> assign_new(:checked, fn -> Phoenix.HTML.Form.normalize_value("checkbox", field.value) end)

    ~H"""
    <div>
      <div phx-feedback-for={@name} class="flex">
        <div class="flex-1">
          <label for={@id} class="font-light leading-tight text-2xl">
            <%= @label %>
          </label>
          <%= render_slot(@inner_block) %>
          <.error :for={msg <- @errors}><%= msg %></.error>
        </div>
        <div class="self-center px-4">
          <div class="flex items-center justify-center w-full">
            <label for={@id} class="flex items-center cursor-pointer">
              <!-- toggle -->
              <div class="relative">
                <!-- input -->
                <input type="hidden" name={@name} value="false" />
                <input
                  type="checkbox"
                  id={@id}
                  name={@name}
                  value="true"
                  checked={@checked}
                  class="sr-only"
                />
                <!-- line -->
                <div class="block bg-gray-600 w-14 h-8 rounded-full"></div>
                <!-- dot -->
                <div class="dot absolute left-1 top-1 bg-white w-6 h-6 rounded-full transition"></div>
              </div>
            </label>
          </div>
        </div>
      </div>

      <%= render_slot(@fields) %>
    </div>
    """
  end
end
