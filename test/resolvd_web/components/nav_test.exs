defmodule ResolvdWeb.NavTest do
  use ResolvdWeb.ConnCase

  import ResolvdWeb.Nav

  test "active path logic" do
    assert active_path(ResolvdWeb.Admin.MailboxLive.Show, ResolvdWeb.Admin.MailboxLive)
    refute active_path(ResolvdWeb.Admin.MailboxLive.Show, ResolvdWeb.Admin.BillingLive)
  end
end
