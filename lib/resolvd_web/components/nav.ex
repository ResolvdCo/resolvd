defmodule ResolvdWeb.Nav do
  use ResolvdWeb, :html

  attr :view, :atom, required: true
  attr :current_user, :any, required: true

  def sidebar(assigns) do
    ~H"""
    <div class="flex overflow-hidden bg-white pt-0 transition-width duration-300">
      <div class="fixed z-30 top-5 left-3 p-2 sm:hidden flex">
        <button type="button" class="-m-2.5 p-2.5 text-gray-700 lg:hidden">
          <span class="sr-only">Open sidebar</span>
          <span phx-click={open_sidebar()} id="sidebar-open-button">
            <.icon name="hero-bars-3" class="w-6 h-6" />
          </span>
          <span phx-click={close_sidebar()} class="hidden" id="sidebar-close-button">
            <.icon name="hero-x-mark" class="w-6 h-6" />
          </span>
        </button>
      </div>
      <div
        id="sidebar"
        class="hidden fixed z-20 h-full top-0 left-0 pt-0 sm:flex flex-shrink-0 flex-col w-16 xl:w-64 transition-width duration-200"
        aria-label="Sidebar"
      >
        <div class="relative flex-1 flex flex-col min-h-0 border-r border-gray-200 bg-white pt-0">
          <div class="flex h-16 shrink-0 justify-center align-center pt-5">
            <img class="hidden xl:flex h-16 w-auto" src={~p"/images/wip-logo.png"} alt="Resolvd" />
            <img
              class="hidden sm:flex xl:hidden pt-3 h-10 w-auto"
              src={~p"/images/wip-logo-small.png"}
              alt="Resolvd"
            />
          </div>
          <div class="flex-1 flex flex-col pt-10 pb-4 overflow-y-auto">
            <div class="flex-1 px-3 bg-white divide-y space-y-1">
              <div class="flex flex-1 flex-col space-y-2 pb-2 h-full justify-between">
                <div class="flex flex-col space-y-2 pb-2">
                  <div :for={item <- sidebar_items()}>
                    <.link
                      navigate={item.to}
                      class={[
                        "text-base text-gray-900 font-normal rounded-lg flex items-center p-2 group w-10 xl:w-auto",
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
                      <span class="hidden ml-3 xl:flex flex-1 whitespace-nowrap">
                        <%= item.label %>
                      </span>
                    </.link>
                  </div>
                </div>
                <div class="flex flex-col space-y-2 pb-2">
                  <div :if={@current_user.is_admin}>
                    <.link
                      navigate={~p"/admin"}
                      class={[
                        "text-base text-gray-900 font-normal rounded-lg flex items-center p-2 group w-10 xl:w-auto",
                        if(active_admin(@view),
                          do: "bg-gray-800 text-white",
                          else: "hover:bg-gray-100"
                        )
                      ]}
                    >
                      <.icon
                        name="hero-cog-6-tooth"
                        class={[
                          "w-6 h-6 text-gray-500 shrink-0  transition duration-75",
                          if(active_admin(@view),
                            do: "text-white",
                            else: "group-hover:text-gray-900"
                          )
                        ]}
                      />
                      <span class="hidden ml-3 xl:flex flex-1 whitespace-nowrap">
                        Admin
                      </span>
                    </.link>
                  </div>
                  <div>
                    <.link
                      href={~p"/users/log_out"}
                      method="delete"
                      class="text-base text-gray-900 font-normal rounded-lg flex items-center p-2 group w-10 xl:w-auto hover:bg-gray-100"
                    >
                      <.icon
                        name="hero-power"
                        class="w-6 h-6 text-gray-500 shrink-0 transition duration-75 group-hover:text-gray-900"
                      />
                      <span class="hidden ml-3 xl:flex flex-1 whitespace-nowrap">
                        <%= "Logout" %>
                      </span>
                    </.link>
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

  defp open_sidebar(js \\ %JS{}) do
    js
    |> toggle_sidebar()
    |> JS.add_class("pl-16", to: "#content")
  end

  defp close_sidebar(js \\ %JS{}) do
    js
    |> toggle_sidebar()
    |> JS.remove_class("pl-16", to: "#content")
  end

  defp toggle_sidebar(js) do
    js
    |> JS.toggle(
      to: "#sidebar",
      display: "flex",
      in: {"ease-in-out duration-200", "-translate-x-16", "translate-x-0"},
      out: {"ease-in-out duration-200", "translate-x-0", "-translate-x-16"},
      time: 200
    )
    |> JS.toggle(to: "#sidebar-open-button")
    |> JS.toggle(to: "#sidebar-close-button")
  end

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
        icon: "hero-user",
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
                  Luke Strickland
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
        icon: "hero-home",
        label: gettext("Categories"),
        module: ResolvdWeb.Admin.CategoryLive
      },
      %{
        to: ~p"/admin/users",
        icon: "hero-home",
        label: gettext("Users"),
        module: ResolvdWeb.Admin.UserLive
      },
      %{
        to: ~p"/admin/billing",
        icon: "hero-chat-bubble-left-right",
        label: gettext("Billing"),
        module: ResolvdWeb.Admin.BillingLive
      },
      %{
        to: ~p"/admin/mailboxes",
        icon: "hero-user",
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
