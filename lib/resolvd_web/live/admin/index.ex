defmodule ResolvdWeb.Admin.IndexLive do
  use ResolvdWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="p-10">
      <.header>
        Admin
      </.header>
    </div>
    """
  end
end
