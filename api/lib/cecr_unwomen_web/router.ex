defmodule CecrUnwomenWeb.Router do
  use CecrUnwomenWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CecrUnwomenWeb do
    pipe_through :api
  end
end
