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
      {Redix, {get_redis_uri(), [name: :redix]}},
      CecrUnwomen.Workers.ConstantWorker,
    ]

    opts = [strategy: :one_for_one, name: CecrUnwomen.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    CecrUnwomenWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def get_redis_uri() do
    System.get_env("REDIS_PASSWORD")
    |> case do
      nil ->
        "redis://localhost:6379"

      pass ->
        "redis://:#{pass}@redis:6379"
    end
  end
end
