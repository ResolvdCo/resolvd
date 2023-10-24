defmodule ResolvdWeb.Nav do
  use ResolvdWeb, :html

  attr :view, :atom, required: true
  attr :current_user, :any, required: true

  def sidebar(assigns) do
    ~H"""
    <div class="flex flex-col items-center py-4 flex-shrink-0 w-20 bg-gray-800 text-gray-200 mr-0">
      <a href="#" class="flex items-center justify-center h-12 w-12">
        <img
          class="pt-3 h-8 w-auto pb-3 box-content"
          src={~p"/images/wip-logo-small.png"}
          alt="Resolvd"
        />
      </a>
      <ul class="flex flex-col space-y-2 mt-12">
        <li :for={item <- sidebar_items()}>
          <.tooltip
            label={item.label}
            class={if(active_path(@view, item.module), do: "hidden", else: "")}
          >
            <.link
              navigate={item.to}
              aria-label={item.label}
              class={[
                "flex items-center justify-center group w-12 h-12 transition-colors duration-200 rounded-2xl",
                if(active_path(@view, item.module),
                  do: "bg-gray-500 text-white",
                  else: "hover:bg-gray-700"
                )
              ]}
            >
              <.icon
                name={item.icon}
                class={[
                  "w-6 h-6 shrink-0 transition-colors duration-200",
                  if(active_path(@view, item.module),
                    do: "text-white",
                    else: "group-hover:text-gray-100"
                  )
                ]}
              />
            </.link>
          </.tooltip>
        </li>
      </ul>
      <div class="mt-auto space-y-2">
        <.tooltip label="Settings" class={if(active_admin(@view), do: "hidden", else: "")}>
          <.link
            navigate={if @current_user.is_admin, do: ~p"/admin", else: ~p"/users/settings"}
            aria-label="Settings"
            class={[
              "flex items-center justify-center w-12 h-12 transition-colors duration-200 rounded-2xl",
              if(active_admin(@view),
                do: "bg-gray-500 text-white",
                else: "hover:bg-gray-700"
              )
            ]}
          >
            <.icon
              name="hero-cog-6-tooth"
              class={[
                "w-6 h-6 shrink-0 transition-colors duration-200",
                if(active_admin(@view),
                  do: "text-white",
                  else: "group-hover:text-gray-100"
                )
              ]}
            />
          </.link>
        </.tooltip>

        <.tooltip label="Log out">
          <.link
            href={~p"/users/log_out"}
            aria-label="Log out"
            method="delete"
            class="flex items-center justify-center group w-12 h-12 transition-colors duration-200 rounded-2xl hover:bg-gray-700"
          >
            <.icon
              name="hero-power"
              class="w-6 h-6 shrink-0 transition-colors duration-200 group-hover:text-gray-100"
            />
          </.link>
        </.tooltip>
      </div>
    </div>
    """
  end

  attr :view, :atom, required: true

  def admin_sidebar(assigns) do
    ~H"""
    <div class="flex flex-col py-5 space-y-4 bg-white w-16 lg:w-56 transition-width duration-200 border-r-2 border-slate-100">
      <div class="flex px-5 pb-4 text-xl font-medium text-gray-800">
        <.icon name="hero-cog-6-tooth" class="shrink-0 w-6 h-7 mr-3" />
        <span class="hidden mal-3 lg:flex">Settings</span>
      </div>

      <div class="mt-2">
        <div :for={item <- user_items()} class="grow">
          <.link
            navigate={item.to}
            class={[
              "text-base text-gray-900 font-normal flex items-center p-4 group xl:w-auto transition-colors duration-200",
              if(active_path(@view, item.module),
                do: "bg-gray-800 text-white",
                else: "hover:bg-gray-100"
              )
            ]}
          >
            <.icon
              name={item.icon}
              class={[
                "w-6 h-6 text-gray-500 shrink-0 transition duration-75",
                if(active_path(@view, item.module),
                  do: "text-white",
                  else: "group-hover:text-gray-900"
                )
              ]}
            />
            <span class="hidden pl-3 lg:flex flex-1 whitespace-nowrap">
              <%= item.label %>
            </span>
          </.link>
        </div>
      </div>

      <div class="flex px-5 pt-8 pb-4 text-xl font-medium text-gray-800">
        <.icon name="hero-user-group" class="shrink-0 w-6 h-7 mr-3" />
        <span class="hidden mal-3 lg:flex">Organization</span>
      </div>
      <div class="mt-2">
        <div :for={item <- admin_items()} class="grow">
          <.link
            navigate={item.to}
            class={[
              "text-base text-gray-900 font-normal flex items-center p-4 group xl:w-auto transition-colors duration-200",
              if(active_path(@view, item.module),
                do: "bg-gray-800 text-white",
                else: "hover:bg-gray-100"
              )
            ]}
          >
            <.icon
              name={item.icon}
              class={[
                "w-6 h-6 text-gray-500 shrink-0 transition duration-75",
                if(active_path(@view, item.module),
                  do: "text-white",
                  else: "group-hover:text-gray-900"
                )
              ]}
            />
            <span class="hidden pl-3 lg:flex flex-1 whitespace-nowrap">
              <%= item.label %>
            </span>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  # defp open_sidebar(js \\ %JS{}) do
  #   js
  #   |> toggle_sidebar()
  #   |> JS.add_class("pl-16", to: "#content")
  # end

  # defp close_sidebar(js \\ %JS{}) do
  #   js
  #   |> toggle_sidebar()
  #   |> JS.remove_class("pl-16", to: "#content")
  # end

  # defp toggle_sidebar(js) do
  #   js
  #   |> JS.toggle(
  #     to: "#sidebar",
  #     display: "flex",
  #     in: {"ease-in-out duration-200", "-translate-x-16", "translate-x-0"},
  #     out: {"ease-in-out duration-200", "translate-x-0", "-translate-x-16"},
  #     time: 200
  #   )
  #   |> JS.toggle(to: "#sidebar-open-button")
  #   |> JS.toggle(to: "#sidebar-close-button")
  # end

  defp sidebar_items do
    [
      %{
        to: ~p"/dashboard",
        icon: "hero-home",
        label: gettext("Dashboard"),
        module: ResolvdWeb.DashboardLive
      },
      %{
        to: ~p"/conversations",
        icon: "hero-chat-bubble-left-right",
        label: gettext("Conversations"),
        module: ResolvdWeb.ConversationLive
      },
      %{
        to: ~p"/customers",
        icon: "hero-user-group",
        label: gettext("Customers"),
        module: ResolvdWeb.CustomerLive
      },
      %{
        to: ~p"/articles",
        icon: "hero-pencil-square",
        label: gettext("Knowledge Base"),
        module: ResolvdWeb.ArticleLive
      },
      %{
        to: ~p"/reports",
        icon: "hero-chart-pie",
        label: gettext("Reports"),
        module: ResolvdWeb.ReportLive
      }
    ]
  end

  attr(:current_user, :any)

  def top(assigns) do
    ~H"""
    <div class="sticky top-0 z-40 flex h-16 shrink-0 items-center gap-x-4 border-b border-gray-200 bg-white px-4 shadow-sm sm:gap-x-6 sm:px-6 lg:px-8">
      <button
        phx-click={JS.show(to: "#mobile-nav")}
        type="button"
        class="-m-2.5 p-2.5 text-gray-700 lg:hidden"
      >
        <span class="sr-only">Open sidebar</span>
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
            d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
          />
        </svg>
      </button>
      <!-- Separator -->
      <div class="h-6 w-px bg-gray-900/10 lg:hidden" aria-hidden="true"></div>

      <div class="flex flex-1 gap-x-4 self-stretch lg:gap-x-6">
        <.live_component id="global-search" module={ResolvdWeb.Components.GlobalSearch} />
        <div class="flex items-center gap-x-4 lg:gap-x-6">
          <div class="relative">
            <button
              type="button"
              class="-m-1.5 flex items-center p-1.5"
              id="user-menu-button"
              aria-expanded="false"
              aria-haspopup="true"
              phx-click={toggle_dropdown("#user-menu")}
            >
              <span class="sr-only">Open user menu</span>
              <img
                class="h-8 w-8 rounded-full bg-gray-50"
                src={Resolvd.Accounts.gravatar_avatar(@current_user)}
                alt=""
              />
              <span class="hidden lg:flex lg:items-center">
                <span class="ml-4 text-sm font-semibold leading-6 text-gray-900" aria-hidden="true">
                  <%= @current_user.name %>
                </span>
                <svg
                  class="ml-2 h-5 w-5 text-gray-400"
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
              </span>
            </button>
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
              id="user-menu"
              class="hidden absolute right-0 z-10 mt-2.5 w-32 origin-top-right rounded-md bg-white py-2 shadow-lg ring-1 ring-gray-900/5 focus:outline-none"
              role="menu"
              aria-orientation="vertical"
              aria-labelledby="user-menu-button"
              tabindex="-1"
            >
              <.link
                navigate={~p"/users/settings"}
                class="block px-3 py-1 text-sm leading-6 text-gray-900"
                role="menuitem"
              >
                Your profile
              </.link>
              <.link
                href={~p"/users/log_out"}
                method="delete"
                class="block px-3 py-1 text-sm leading-6 text-gray-900"
                role="menuitem"
              >
                Log out
              </.link>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr(:view, :atom, required: true)

  def admin(assigns) do
    ~H"""
    <div class="border-b border-gray-200 pb-5 sm:pb-0">
      <h3 class="text-base font-semibold leading-6 text-gray-900">Admin</h3>
      <div class="mt-3 sm:mt-4">
        <!-- Dropdown menu on small screens -->
        <div class="sm:hidden">
          <label for="current-tab" class="sr-only">Select a tab</label>
          <select
            id="current-tab"
            name="current-tab"
            class="block w-full rounded-md border-gray-300 py-2 pl-3 pr-10 text-base focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm"
          >
            <option>Settings</option>
            <option>Billing</option>
            <option selected>Mailboxes</option>
            <option>Offer</option>
            <option>Hired</option>
          </select>
        </div>
        <!-- Tabs at small breakpoint and up -->
        <div class="hidden sm:block">
          <nav class="-mb-px flex space-x-8">
            <!-- Current: "border-indigo-500 text-indigo-600", Default: "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700" -->
            <.link
              :for={item <- admin_items()}
              navigate={item.to}
              class={[
                "text-gray-500 hover:border-gray-300 hover:text-gray-700 whitespace-nowrap border-b-2 px-1 pb-4 text-sm font-medium",
                if(active_path(@view, item.module),
                  do: "border-indigo-500 text-indigo-600 ",
                  else: "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700"
                )
              ]}
            >
              <%= item.label %>
            </.link>
          </nav>
        </div>
      </div>
    </div>
    """
  end

  attr :class, :any, default: nil
  attr :label, :string, required: true
  slot :inner_block, required: true

  def tooltip(assigns) do
    ~H"""
    <div class="relative group">
      <%= render_slot(@inner_block) %>

      <span class={[
        "opacity-0 group-hover:opacity-100 group-hover:hover:opacity-0 transition-opacity absolute whitespace-nowrap bg-gray-600 text-white text-center rounded-md px-2 py-1 top-2 z-30 left-[120%]",
        "after:absolute after:top-[50%] after:right-[100%] after:-mt-[5px] after:border-[5px] after:border-transparent after:border-r-gray-600",
        @class
      ]}>
        <%= @label %>
      </span>
    </div>
    """
  end

  defp user_items do
    [
      %{
        to: ~p"/users/settings",
        icon: "hero-user-circle",
        label: gettext("Profile"),
        module: ResolvdWeb.UserSettingsLive
      }
    ]
  end

  defp admin_items do
    [
      %{
        to: ~p"/admin",
        icon: "hero-home",
        label: gettext("Home"),
        module: ResolvdWeb.Admin.IndexLive
      },
      %{
        to: ~p"/admin/categories",
        icon: "hero-tag",
        label: gettext("Categories"),
        module: ResolvdWeb.Admin.CategoryLive
      },
      %{
        to: ~p"/admin/users",
        icon: "hero-user-plus",
        label: gettext("Users"),
        module: ResolvdWeb.Admin.UserLive
      },
      %{
        to: ~p"/admin/billing",
        icon: "hero-credit-card",
        label: gettext("Billing"),
        module: ResolvdWeb.Admin.BillingLive
      },
      %{
        to: ~p"/admin/mailboxes",
        icon: "hero-at-symbol",
        label: gettext("Mailboxes"),
        module: ResolvdWeb.Admin.MailboxLive
      }
    ]
  end

  defp active_admin(actual) do
    ["ResolvdWeb", second | _rest] = Module.split(actual)
    second == "Admin"
  end

  def active_path(actual, test) do
    # Weird defaults to ensure they don't match if Live isn't found
    actual_view = Module.split(actual) |> Enum.find("actual", &String.ends_with?(&1, "Live"))
    test_view = Module.split(test) |> Enum.find("test", &String.ends_with?(&1, "Live"))
    actual_view == test_view
  end
end
