defmodule Squidtree.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      # SquidtreeWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Squidtree.PubSub},
      # Start the Endpoint (http/https)
      SquidtreeWeb.Endpoint,
      # Start a worker by calling: Squidtree.Worker.start_link(arg)
      # {Squidtree.Worker, arg}
      {Squidtree.DocumentServer, name: Squidtree.DocumentServer},
      Squidtree.DocumentIndexTask
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Squidtree.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SquidtreeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
