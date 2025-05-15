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
      post "/delete_user", UserController, :delete_user
      post "/get_info", UserController, :get_info
      post "/update_info", UserController, :update_info
      post "/set_time_reminded", UserController, :set_time_reminded
      post "/change_password", UserController, :change_password
      post "/add_firebase_token", UserController, :add_firebase_token
      post "/get_list_user_of_type", UserController, :get_list_user_of_type
      post "/search_user_for_admin", UserController, :search_user_for_admin
      post "/delete_user_for_admin", UserController, :delete_user_for_admin
    end

    scope "/upload" do
      pipe_through :token
      post "/upload_avatar", UploadController, :upload_avatar
    end

    scope "/contribution" do
      pipe_through :token
      get "/get_overall_data", ContributionController, :get_overall_data
      get "/get_filter_overall_data", ContributionController, :get_filter_overall_data
      get "/get_detail_contribution_by_time", ContributionController, :get_detail_contribution_by_time
      get "/get_overall_contribution", ContributionController, :get_overall_contribution
      post "/contribute_data", ContributionController, :contribute_data
      post "/edit_factor_quantity", ContributionController, :edit_factor_quantity
      post "/get_detail_contribution", ContributionController, :get_detail_contribution
      post "/remove_contribution", ContributionController, :remove_contribution
      post "/search_contribution", ContributionController, :search_contribution
    end
  end
end
