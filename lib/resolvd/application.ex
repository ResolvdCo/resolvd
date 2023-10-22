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
      {DNSCluster, query: Application.get_env(:resolvd, :dns_cluster_query) || :ignore},
      # Start the PubSub system
      {Phoenix.PubSub, name: Resolvd.PubSub},
      # Start Finch
      {Finch, name: Resolvd.Finch},
      # Start the Endpoint (http/https)
      ResolvdWeb.Endpoint,
      {Registry, [keys: :unique, name: :inbound_pair_supervisors]},
      Resolvd.Mailboxes.Inbound.Supervisor,
      Resolvd.Mailboxes.Inbound.Manager,
      {Oban, Application.fetch_env!(:resolvd, Oban)}
    ]

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
