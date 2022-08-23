defmodule Relayd.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = [
      nomad: [
        strategy: Cluster.Strategy.Nomad,
        config: [
          service_name: "relayd",
          nomad_server_url: "http://127.0.0.1:4646",
          namespace: "default",
          node_basename: "relayd",
          token: "4649b287-1213-6080-8b77-f115f5b4e8e0",
          polling_interval: 5_000
        ]
      ]
    ]

    children = [
      # Start the Ecto repository
      Relayd.Repo,
      # Start the Telemetry supervisor
      RelaydWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Relayd.PubSub},
      # Start the Endpoint (http/https)
      RelaydWeb.Endpoint,
      # Start a worker by calling: Relayd.Worker.start_link(arg)
      # {Relayd.Worker, arg},
      {Cluster.Supervisor, [topologies, [name: MyApp.ClusterSupervisor]]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Relayd.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RelaydWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
