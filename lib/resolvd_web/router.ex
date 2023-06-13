defmodule ResolvdWeb.Router do
  use ResolvdWeb, :router

  import ResolvdWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ResolvdWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", ResolvdWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:resolvd, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ResolvdWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  # Marketing Routes
  # scope "/", ResolvdWeb.Marketing do
  #   pipe_through :browser

  #   live_session :default, layout: {ResolvdWeb.Layouts, :marketing} do
  #     live "/", HomeLive
  #   end

  #   # get "/", PageController, :home
  # end

  # Authentication Routes

  scope path: "/", host: "resolvd.local", alias: ResolvdWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      layout: {ResolvdWeb.Layouts, :auth},
      on_mount: [{ResolvdWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", host: "resolvd.local", alias: ResolvdWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      layout: {ResolvdWeb.Layouts, :auth},
      on_mount: [{ResolvdWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  # App Routes
  scope "/", host: "resolvd.local", alias: ResolvdWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ResolvdWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      live "/", DashboardLive.Index, :index
      live "/dashboard", DashboardLive.Index, :index

      live "/conversations", ConversationLive.Index, :index
      live "/conversations/new", ConversationLive.Index, :new
      live "/conversations/:id/edit", ConversationLive.Index, :edit

      live "/conversations/:id", ConversationLive.Show, :show
      live "/conversations/:id/show/edit", ConversationLive.Show, :edit

      # live "/messages", MessageLive.Index, :index
      # live "/messages/new", MessageLive.Index, :new
      # live "/messages/:id/edit", MessageLive.Index, :edit

      # live "/messages/:id", MessageLive.Show, :show
      # live "/messages/:id/show/edit", MessageLive.Show, :edit

      live "/customers", CustomerLive.Index, :index
      live "/customers/new", CustomerLive.Index, :new
      live "/customers/:id/edit", CustomerLive.Index, :edit

      live "/customers/:id", CustomerLive.Show, :show
      live "/customers/:id/show/edit", CustomerLive.Show, :edit

      live "/articles", ArticleLive.Index, :index
      live "/articles/new", ArticleLive.Index, :new
      live "/articles/:id/edit", ArticleLive.Index, :edit

      live "/articles/:id", ArticleLive.Show, :show
      live "/articles/:id/show/edit", ArticleLive.Show, :edit
    end
  end

  scope "/admin", host: "resolvd.local", alias: ResolvdWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin_user]

    live_session :require_admin_user,
      on_mount: [{ResolvdWeb.UserAuth, :ensure_admin}] do
      live "/categories", CategoryLive.Index, :index
      live "/categories/new", CategoryLive.Index, :new
      live "/categories/:id/edit", CategoryLive.Index, :edit

      live "/categories/:id", CategoryLive.Show, :show
      live "/categories/:id/show/edit", CategoryLive.Show, :edit

      live "/mail-servers", MailServerLive.Index, :index
      live "/mail-servers/new", MailServerLive.Index, :new
      live "/mail-servers/:id/edit", MailServerLive.Index, :edit

      live "/mail-servers/:id", MailServerLive.Show, :show
      live "/mail-servers/:id/show/edit", MailServerLive.Show, :edit
    end
  end

  scope "/", host: "*.resolvd.local", alias: ResolvdWeb do
    pipe_through :browser

    live_session :default, layout: {ResolvdWeb.Layouts, :tenant} do
      live "/", Tenant.HomeLive
    end
  end

  # def extract_tenant(%Plug.Conn{host: host} = conn, )
end
