defmodule ResolvdWeb.Admin.IndexLive do
  use ResolvdWeb, :admin_live_view

  def render(assigns) do
    ~H"""
    <.header>
      Admin
    </.header>
    """
  end
end
