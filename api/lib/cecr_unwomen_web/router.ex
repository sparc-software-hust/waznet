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
      post "/update_info", UserController, :update_info
      post "/change_password", UserController, :change_password
      post "/add_firebase_token", UserController, :add_firebase_token
    end

    scope "/upload" do
      pipe_through :token
      post "/upload_avatar", UploadController, :upload_avatar
    end

    scope "/contribution" do
      pipe_through :token
      post "/contribute_scrap_data", ContributionController, :contribute_scrap_data
      post "/contribute_household_data", ContributionController, :contribute_household_data
      post "/edit_factor_quantity", ContributionController, :edit_factor_quantity
      get "/get_contribution_for_user", ContributionController, :get_contribution_for_user
    end
  end
end
