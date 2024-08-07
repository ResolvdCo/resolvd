defmodule ResolvdWeb.StylesLive do
  use ResolvdWeb, :live_view

  import ResolvdWeb.WindmillComponents

  defp fake_data do
    Enum.map(1..10, fn _ ->
      %{
        subject: Faker.Lorem.sentence(5, ""),
        sender: Faker.Internet.safe_email()
      }
    end)
  end

  def mount(params, session, socket) do
    {:ok, socket |> assign(:form, to_form(%{}))}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <div>
        <.header>Cards and forms</.header>

        <.card>
          <.simple_form for={@form} phx-change="validate" phx-submit="save">
            <.input type="text" field={@form[:name]} label="Name" />
            <.input
              type="select"
              options={["a", "b", "c", "d"]}
              field={@form[:select]}
              label="Select"
            />
            <.input type="textarea" field={@form[:text]} label="Text" />
            <:actions>
              <.button>Save</.button>
            </:actions>
          </.simple_form>
        </.card>
      </div>

      <div>
        <.header>Buttons</.header>
        <.button>Hello world!</.button>
        <.button phx-click="go" class="ml-2">Submit</.button>
      </div>

      <div>
        <.header>Table</.header>
        <.table id="foo" rows={fake_data()} row_click={fn row -> nil end}>
          <:col :let={row} label="Subject">
            <div class="flex items-center text-sm">
              <!-- Avatar with inset shadow -->
              <div class="relative hidden w-8 h-8 mr-3 rounded-full md:block">
                <img
                  class="object-cover w-full h-full rounded-full"
                  src="https://images.unsplash.com/flagged/photo-1570612861542-284f4c12e75f?ixlib=rb-1.2.1&amp;q=80&amp;fm=jpg&amp;crop=entropy&amp;cs=tinysrgb&amp;w=200&amp;fit=max&amp;ixid=eyJhcHBfaWQiOjE3Nzg0fQ"
                  alt=""
                  loading="lazy"
                />
                <div class="absolute inset-0 rounded-full shadow-inner" aria-hidden="true"></div>
              </div>
              <div>
                <p class="font-semibold"><%= row.sender %></p>
                <p class="text-gray-600 dark:text-gray-400">
                  <%= row.subject %>
                </p>
              </div>
            </div>
          </:col>
          <:col :let={_row} label="Status">
            <span class="px-2 py-1 font-semibold leading-tight text-green-700 bg-green-100 rounded-full dark:bg-green-700 dark:text-green-100">
              Resolved
            </span>
          </:col>
          <:action :let={_row}>
            <.link navigate="#">Show</.link>
          </:action>
        </.table>
      </div>

      <div>
        <.header>Cards</.header>

        <.card>
          Hello world!
        </.card>

        <div class="py-4 grid grid-cols-4 gap-4">
          <.card>
            Hello world!
          </.card>
          <.card>
            Hello world!
          </.card>
          <.card>
            Hello world!
          </.card>
          <.card>
            Hello world!
          </.card>
        </div>
      </div>
    </div>
    """
  end
end
