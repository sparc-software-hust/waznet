defmodule CecrUnwomenWeb.AuthController do
  alias CecrUnwomen. {Utils.Helper, Repo}
  alias CecrUnwomen.Models.User
  use CecrUnwomenWeb, :controller

  def renew_access_token(conn, _) do
    user_id = conn.assigns.user.user_id
    refresh_token_from_conn = conn.assigns.user.refresh_token

    res = Repo.get_by(User, %{id: user_id, refresh_token: refresh_token_from_conn})
    |> case do
      nil -> Helper.response_json_message(false, "Người dùng không tồn tại", 400)
      user ->
        role_id = conn.assigns.user.role_id
        data_jwt = %{
          "user_id" => user_id,
          "role_id" => role_id
        }
        expires_in = conn.assigns.user.exp
        new_refresh_token = Helper.create_token(data_jwt, :refresh_token, expires_in)
        new_access_token = Helper.create_token(data_jwt, :access_token)

        Ecto.Changeset.change(user, %{refresh_token: new_refresh_token})
        |> Repo.update
        |> case do
          {:ok, _} ->
            res_data = %{
              "refresh_token" => new_refresh_token,
              "access_token" => new_access_token
            }
            Helper.response_json_with_data(true, "Làm mới at thành công", res_data)

          _ -> Helper.response_json_message(false, "Không thể cập nhật at", 400)
        end
    end
    json conn, res
  end
end
