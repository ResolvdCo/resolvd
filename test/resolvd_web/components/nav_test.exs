defmodule ResolvdWeb.NavTest do
  use ResolvdWeb.ConnCase

  import ResolvdWeb.Nav

  test "active path logic" do
    assert active_path(ResolvdWeb.Admin.MailServerLive.Show, ResolvdWeb.Admin.MailServerLive)
    refute active_path(ResolvdWeb.Admin.MailServerLive.Show, ResolvdWeb.Admin.BillingLive)
  end
end
