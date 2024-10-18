defmodule CecrUnwomenWeb.Router do
  use CecrUnwomenWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :token do
    plug CecrUnwomenWeb.AuthPlug
  end

  scope "/api", CecrUnwomenWeb do
    pipe_through :api

    scope "/user" do
      post "/register", UserController, :register
      post "/login", UserController, :login

      scope "/:user_id" do
        pipe_through :token
        post "/logout", UserController, :logout
      end
    end
  end
end
