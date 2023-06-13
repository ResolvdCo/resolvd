defmodule ResolvdWeb.Sidebar do
  use ResolvdWeb, :html

  defp items do
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

  attr :view, :atom, required: true

  def sidebar_items(assigns) do
    ~H"""
    <li :for={item <- items()}>
      <.link
        navigate={item.to}
        class={[
          "group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold",
          if(active_path(@view, item.module),
            do: "bg-indigo-700 text-white",
            else: "text-indigo-200 hover:text-white hover:bg-indigo-700"
          )
        ]}
      >
        <.icon name={item.icon} class="h-6 w-6 shrink-0 text-indigo-200 group-hover:text-white" /> <%= item.label %>
      </.link>
    </li>
    """
  end

  defp active_path(view, module) do
    ["ResolvdWeb", view_name | _rest] = Module.split(view)
    ["ResolvdWeb", module_name | _rest] = Module.split(module)
    view_name == module_name
  end
end
