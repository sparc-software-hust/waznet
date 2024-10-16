defmodule CecrUnwomen.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      CecrUnwomenWeb.Telemetry,
      # Start the Ecto repository
      CecrUnwomen.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: CecrUnwomen.PubSub},
      # Start the Endpoint (http/https)
      CecrUnwomenWeb.Endpoint
      # Start a worker by calling: CecrUnwomen.Worker.start_link(arg)
      # {CecrUnwomen.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CecrUnwomen.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CecrUnwomenWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
