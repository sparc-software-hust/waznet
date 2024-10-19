defmodule CecrUnwomenWeb.Router do
  use CecrUnwomenWeb, :router

  # pipeline :browser do
  #   plug :accepts, ["html"]
  #   plug :fetch_session
  #   plug :protect_from_forgery
  #   plug :put_secure_browser_headers
  # end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :token do
    plug CecrUnwomenWeb.AuthPlug
  end

  scope "/api", CecrUnwomenWeb do
    pipe_through :api

    scope "/auth" do
      pipe_through :token
      post "/renew_access_token", AuthController, :renew_access_token
    end

    scope "/user" do
      post "/register", UserController, :register
      post "/login", UserController, :login

      pipe_through :token
      post "/logout", UserController, :logout
      post "/get_info", UserController, :get_info
      post "/change_password", UserController, :change_password
    end
  end

  # scope "/", CecrUnwomenWeb do
  #   pipe_through :browser
  # end
end
