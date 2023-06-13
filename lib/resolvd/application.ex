defmodule Resolvd.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ResolvdWeb.Telemetry,
      # Start the Ecto repository
      Resolvd.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Resolvd.PubSub},
      # Start Finch
      {Finch, name: Resolvd.Finch},
      # Start the Endpoint (http/https)
      ResolvdWeb.Endpoint,
      Resolvd.Mailbox.InboundSupervisor
      # Start a worker by calling: Resolvd.Worker.start_link(arg)
      # {Resolvd.Worker, arg}
      # Yugo.Client instantiation should be moved to the MailProcessor (processor should start / supervise)
      # {
      #   Yugo.Client,
      #   name: :resolvd,
      #   server: Application.get_env(:resolvd, Yugo.Client)[:server],
      #   username: Application.get_env(:resolvd, Yugo.Client)[:username],
      #   password: Application.get_env(:resolvd, Yugo.Client)[:password]
      # },
      # Resolvd.Mailbox.MailProcessor
    ]

    :observer.start()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Resolvd.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ResolvdWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
