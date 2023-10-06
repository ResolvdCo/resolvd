defmodule ResolvdWeb.Nav do
  use ResolvdWeb, :html

  attr :view, :atom, required: true
  attr :current_user, :any, required: true

  def sidebar(assigns) do
    ~H"""
    <div class="flex flex-col items-center w-16 xl:w-64 py-2 space-y-4 bg-white transition-width duration-200 border-r-2 border-slate-100">
      <a href="#" class="pb-2">
        <img class="hidden xl:block h-16 w-auto" src={~p"/images/wip-logo.png"} alt="Resolvd" />
        <img
          class="block xl:hidden pt-3 h-10 w-auto pb-3 box-content"
          src={~p"/images/wip-logo-small.png"}
          alt="Resolvd"
        />
      </a>

      <div class="flex flex-col flex-1 w-full">
        <div :for={item <- sidebar_items()} class="w-full">
          <.link
            navigate={item.to}
            class={[
              "text-base text-gray-900 font-normal flex items-center p-4 group w-full xl:w-auto",
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
            <span class="hidden pl-3 xl:flex flex-1 whitespace-nowrap">
              <%= item.label %>
            </span>
          </.link>
        </div>
      </div>

      <div class="w-full">
        <.link
          navigate={if @current_user.is_admin, do: ~p"/admin", else: ~p"/users/settings"}
          class={[
            "text-base text-gray-900 font-normal flex items-center p-4 group w-full xl:w-auto",
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
            Settings
          </span>
        </.link>
      </div>

      <div class="w-full pb-10">
        <.link
          href={~p"/users/log_out"}
          method="delete"
          class="text-base text-gray-900 font-normal flex items-center p-4 group w-full xl:w-auto hover:bg-gray-100"
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
    """
  end

  attr :view, :atom, required: true

  def admin_sidebar(assigns) do
    ~H"""
    <div class="flex flex-col py-5 space-y-4 bg-white w-16 md:w-64 transition-width duration-200 border-r-2 border-slate-100">
      <h2 class="px-5 pb-8 text-xl font-medium text-gray-800 items-center">Settings</h2>

      <div class="mt-2">
        <div :for={item <- admin_items()} class="w-full">
          <.link
            navigate={item.to}
            class={[
              "text-base text-gray-900 font-normal flex items-center p-4 group w-full xl:w-auto",
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
            <span class="hidden pl-3 md:flex flex-1 whitespace-nowrap">
              <%= item.label %>
            </span>
          </.link>
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

  defp admin_items do
    [
      %{
        to: ~p"/admin",
        icon: "hero-home",
        label: gettext("Home"),
        module: ResolvdWeb.Admin.IndexLive
      },
      %{
        to: ~p"/users/settings",
        icon: "hero-user-circle",
        label: gettext("Profile"),
        module: ResolvdWeb.UserSettingsLive
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
