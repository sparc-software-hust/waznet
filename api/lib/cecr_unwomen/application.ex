defmodule CecrUnwomen.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CecrUnwomenWeb.Telemetry,
      CecrUnwomen.Repo,
      {Phoenix.PubSub, name: CecrUnwomen.PubSub},
      CecrUnwomenWeb.Endpoint,
      CecrUnwomen.Fcm.FcmStore,
      CecrUnwomen.Consumer,
      {Redix, {"redis://localhost:6379", [name: :redix]}}
    ]

    opts = [strategy: :one_for_one, name: CecrUnwomen.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    CecrUnwomenWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
