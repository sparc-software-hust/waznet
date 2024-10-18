defmodule CecrUnwomenWeb.UserController do
  use CecrUnwomenWeb, :controller
  alias CecrUnwomen.{Utils.Helper, Repo}
  alias CecrUnwomen.Models.{User, Role}
  import Ecto.Query

  def register(conn, params) do
    phone_number = params["phone_number"]
    first_name = params["first_name"]
    last_name = params["last_name"]
    plain_password = params["password"]

    is_pass_phone_number = validate_phone_number_length(phone_number) && !has_user_with_phone_number(phone_number)
    is_pass_password = validate_password_length(plain_password)

    is_ready_to_insert = !is_nil(first_name) && !is_nil(last_name) && is_pass_password
    response = cond do
      !is_pass_phone_number -> Helper.response_json_message(false, "Số điện thoại không đúng hoặc đã tồn tại!", 279)
      !is_ready_to_insert -> Helper.response_json_message(false, "Bạn nhập thiếu các thông tin cần thiết! Vui lòng kiểm tra lại!", 301)
      true ->
        # TODO: validate role for admin
        init_role_id = 2
        user_id = Ecto.UUID.generate()
        password_hash = Argon2.hash_pwd_salt(plain_password)
        access_token = create_token(%{
          "user_id" => user_id,
          "role_id" => init_role_id
        })

        User.changeset(%User{}, %{
          id: user_id,
          first_name: first_name,
          last_name: last_name,
          role_id: init_role_id,
          phone_number: phone_number,
          password_hash: password_hash,
          access_token: access_token
        })
        |> Repo.insert
        |> case do
          {:ok, user} -> 
            Map.from_struct(user) |> IO.inspect(label: "hahaha")
            Helper.response_json_message(true, "Tạo tài khoản thành công")

          _ -> Helper.response_json_message(false, "Không thể tạo tài khoản, vui lòng liên hệ quản trị viên!", 300)
        end
    end

    json conn, response
  end

  def login(conn, params) do
    phone_number = params["phone_number"]
    plain_password = params["password"]

    is_pass_phone_number = validate_phone_number_length(phone_number) && has_user_with_phone_number(phone_number)
    is_pass_password_length = validate_password_length(plain_password)

    res = cond do
      !is_pass_phone_number -> Helper.response_json_message(false, "Không tìm thấy số điện thoại!", 280)
      !is_pass_password_length -> Helper.response_json_message(false, "Sai số điện thoại hoặc mật khẩu", 301)
      true ->
        from(u in User, where: u.phone_number == ^phone_number, select: u)
        |> Repo.one
        |> case do
          nil -> Helper.response_json_message(false, "Không tìm thấy tài khoản!", 302)
          user ->
            Argon2.verify_pass(plain_password, user.password_hash)
            |> case do
              false -> Helper.response_json_message(false, "Sai tài khoản hoặc mật khẩu!", 282)
              true ->
                access_token = create_token(%{
                  "user_id" => user.id,
                  "role_id" => user.role_id
                })

                Ecto.Changeset.change(user, %{access_token: access_token})
                # TODO: blacklist revoked token?? (redis, genserver)
                |> Repo.update
                |> case do
                  {:ok, updated_user} ->
                    res_data = %{
                      "access_token" => updated_user.access_token,
                      "user_id" => user.id,
                      "role_id" => user.role_id,
                      "first_name" => user.first_name,
                      "last_name" => user.last_name
                    }
                    Helper.response_json_with_data(true, "Đăng nhập thành công", res_data)

                  _ -> Helper.response_json_message(false, "Có lỗi xảy ra!", 303)
                end

              _ -> Helper.response_json_message(false, "Có lỗi xảy ra!", 303)
            end
        end
    end

    json conn, res
  end

  def logout(conn, params) do
    user_id = conn.assigns.user.user_id

    # TODO: add token to blacklist with redis
    Repo.get_by(User, id: user_id)
    |> case do
      nil -> IO.inspect(label: "no")
      user -> IO.inspect(user, label: "hehe")
    end
    res = Helper.response_json_message(false, "Có lỗi xảy ra!", 303)
    json conn, res
  end

  def create_token(claims) do
    secret_key = Application.get_env(:cecr_unwomen, CecrUnwomenWeb.Endpoint)[:secret_key_base]

    jwk = %{
      "kty" => "oct",
      "k" => :jose_base64url.encode(secret_key)
    }

    jws = %{"alg" => "HS256"}

    iat = DateTime.utc_now() |> DateTime.to_unix(:second)
    exp = iat + 63_072_000

    jwt =
      %{
        "iss" => "cecr_unwomen",
        "iat" => iat,
        "exp" => exp
      }
      |> Map.merge(claims)

    JOSE.JWT.sign(jwk, jws, jwt)
    |> JOSE.JWS.compact()
    |> elem(1)
  end

  defp validate_password_length(plain_password) do
    password_length = if is_nil(plain_password), do: -1, else: String.length(plain_password)
    if password_length < 8, do: false, else: true
  end

  defp has_user_with_phone_number(phone_number) do
    from(u in User, where: u.phone_number == ^phone_number)
    |> Repo.exists?()
  end

  defp validate_phone_number_length(phone_number) do
    phone_number_length = if is_nil(phone_number), do: -1, else: String.length(phone_number)
    if phone_number_length == 10, do: true, else: false
  end

  def verify_token(token) do
    Helper.validate_token(token)
  end
end
