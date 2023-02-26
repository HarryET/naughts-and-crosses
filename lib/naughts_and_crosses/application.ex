defmodule NaughtsAndCrosses.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    NaughtsAndCrosses.Release.migrate()

    children = [
      # Start the Telemetry supervisor
      NaughtsAndCrossesWeb.Telemetry,
      # Start the Ecto repository
      NaughtsAndCrosses.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: NaughtsAndCrosses.PubSub},
      # Start the Endpoint (http/https)
      NaughtsAndCrossesWeb.Endpoint
      # Start a worker by calling: NaughtsAndCrosses.Worker.start_link(arg)
      # {NaughtsAndCrosses.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NaughtsAndCrosses.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NaughtsAndCrossesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
