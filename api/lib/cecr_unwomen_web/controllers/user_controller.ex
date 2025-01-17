defmodule CecrUnwomenWeb.UserController do
  use CecrUnwomenWeb, :controller
  alias CecrUnwomen.{Utils.Helper, Repo, RedisDB}
  alias CecrUnwomenWeb.Models.{User, FirebaseToken}
  import Ecto.Query

  def register(conn, params) do
    phone_number = params["phone_number"]
    first_name = params["first_name"]
    last_name = params["last_name"]
    plain_password = params["password"]
    role_id = params["role_id"]
    code = params["code"]
    birth = params["birth"]
    gender = params["gender"]
    location = params["location"]

    is_pass_phone_number = validate_phone_number_length(phone_number) && !has_user_with_phone_number(phone_number)
    is_pass_password = validate_password_length(plain_password)
    is_pass_admin_role = role_id == 1 && code == "03120045" || role_id != 1

    is_ready_to_insert = !is_nil(first_name) && !is_nil(last_name) && is_pass_password
    response = cond do
      !is_pass_phone_number -> Helper.response_json_message(false, "Số điện thoại đã tồn tại hoặc đã bị xoá khỏi hệ thống", 279)
      !is_ready_to_insert -> Helper.response_json_message(false, "Bạn nhập thiếu các thông tin cần thiết! Vui lòng kiểm tra lại!", 301)
      !is_pass_admin_role -> Helper.response_json_message(false, "Bạn không thể đăng ký làm admin!", 301)
      true ->
        # TODO: validate role for admin
        user_id = Ecto.UUID.generate()
        password_hash = Argon2.hash_pwd_salt(plain_password)
        data_jwt = %{
          "user_id" => user_id,
          "role_id" => role_id
        }

        {_, refresh_token, _} = Helper.create_token(data_jwt, :refresh_token)
        {_, access_token, access_exp} = Helper.create_token(data_jwt, :access_token)

        birth = if is_nil(birth), do: nil, else:  
          String.split(birth, "T")
          |> List.first()
          |> Date.from_iso8601!()

        User.changeset(%User{}, %{
          id: user_id,
          first_name: first_name,
          last_name: last_name,
          role_id: role_id,
          phone_number: phone_number,
          password_hash: password_hash,
          refresh_token: refresh_token,
          date_of_birth: birth,
          location: location,
          gender: gender
        })
        |> Repo.insert
        |> case do
          {:ok, user} ->
            user_map = Helper.get_user_map_from_struct(user)
              # |> Map.drop([:location, :avatar_url, :date_of_birth, :email])
            RedisDB.update_user(user_map)
            res_data = %{
              "access_token" => access_token,
              "access_exp" => access_exp,
              "refresh_token" => user.refresh_token,
              "user" => user_map
            }
            Helper.response_json_with_data(true, "Tạo tài khoản thành công", res_data)

          {:error, e} ->
            IO.inspect(e, label: "gndkjfd")
            Helper.response_json_message(false, "Không thể tạo tài khoản, vui lòng liên hệ quản trị viên!", 300)
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
        from(u in User, where: u.phone_number == ^phone_number and u.is_removed != true, select: u)
        |> Repo.one
        |> case do
          nil -> Helper.response_json_message(false, "Không tìm thấy tài khoản!", 302)
          user ->
            Argon2.verify_pass(plain_password, user.password_hash)
            |> case do
              false -> Helper.response_json_message(false, "Sai tài khoản hoặc mật khẩu!", 282)
              true ->
                data_jwt = %{
                  "user_id" => user.id,
                  "role_id" => user.role_id
                }

                {_, refresh_token, _} = Helper.create_token(data_jwt, :refresh_token)
                {_, access_token, access_exp} = Helper.create_token(data_jwt, :access_token)

                Ecto.Changeset.change(user, %{refresh_token: refresh_token})
                |> Repo.update
                |> case do
                  {:ok, updated_user} ->
                    user_map = Helper.get_user_map_from_struct(updated_user)
                      # |> Map.drop([:location, :avatar_url, :date_of_birth, :email])
                    RedisDB.update_user(user_map)
                    res_data = %{
                      "access_token" => access_token,
                      "access_exp" => access_exp,
                      "refresh_token" => updated_user.refresh_token,
                      "user" => user_map
                    }
                    Helper.response_json_with_data(true, "Đăng nhập thành công", res_data)

                  _ -> Helper.response_json_message(false, "Có lỗi xảy ra!", 303)
                end
            end
        end
    end

    json conn, res
  end

  def delete_user(conn, _params) do
    user_id = conn.assigns.user.user_id
    res = Repo.get_by(User, %{id: user_id, is_removed: false})
    |> case do
      nil -> Helper.response_json_message(false, "Không tìm thấy người dùng!", 300)
      user ->
        Ecto.Changeset.change(user, %{is_removed: true, refresh_token: nil})
        |> Repo.update
        |> case do
          {:ok, _} -> Helper.response_json_message(true, "Xóa người dùng thành công!")
          _ -> Helper.response_json_message(false, "Có lỗi xảy ra!", 303)
        end
    end
    json conn, res
  end

  def logout(conn, _params) do
    # user_id = params["user_id"]
    user_id = conn.assigns.user.user_id

    # TODO: add token to blacklist with redis
    res = Repo.get_by(User, id: user_id)
    |> case do
      nil -> Helper.response_json_message(false, "Không tìm thấy người dùng!", 300)
      user ->
        Ecto.Changeset.change(user, %{refresh_token: nil})
        |> Repo.update
        |> case do
          nil -> Helper.response_json_message(false, "Có lỗi xảy ra!", 303)
          _ ->
            Helper.response_json_message(true, "Đăng xuất thành công")
        end
    end
    json conn, res
  end


  def get_info(conn, params) do
    user_id = params["user_id"]

    response = RedisDB.get_user(user_id)
    |> case do
      nil ->
        Repo.get_by(User, id: user_id)
        |> case do
          nil -> Helper.response_json_message(false, "Không tìm thấy người dùng!", 300)
          user ->
            user_map = Helper.get_user_map_from_struct(user)
            RedisDB.update_user(user_map)
            Helper.response_json_with_data(true, "Lấy thông tin người dùng thành công", user_map)
        end
      user -> Helper.response_json_with_data(true, "Lấy thông tin người dùng thành công", user)
    end
    json conn, response
  end


  def update_info(conn, params) do
    user_id = conn.assigns.user.user_id

    response = Repo.get_by(User, id: user_id)
    |> case do
      nil -> Helper.response_json_message(false, "Không tìm thấy người dùng!", 300)
      user ->
        keys = ["first_name", "last_name", "date_of_birth", "email", "gender", "location"]
        data_changes = Enum.reduce(keys, %{}, fn key, acc ->
          key_atom = String.to_atom(key)
          value = case key do
            "date_of_birth" -> 
              if (!is_nil(params[key])) do
                String.split(params[key], "T")
                |> List.first()
                |> Date.from_iso8601!()
              end
              
            _ -> params[key]
          end
          if params[key], do: Map.put(acc, key_atom, value), else: acc
        end)
        Ecto.Changeset.change(user, data_changes)
        |> Repo.update
        |> case do
          {:ok, updated_user} ->
            updated_user_map = Helper.get_user_map_from_struct(updated_user)
            RedisDB.update_user(updated_user_map)
            Helper.response_json_with_data(true, "Cập nhật thông tin người dùng thành công!", updated_user_map)

          _ -> Helper.response_json_message(false, "Không thể cập nhật thông tin!", 321)
        end
    end
    json conn, response
  end
  
  def set_time_reminded(conn, params) do
    user_id = conn.assigns.user.user_id
    time_reminded = params["time_reminded"]

    response = Repo.get_by(User, id: user_id)
    |> case do
      nil -> Helper.response_json_message(false, "Không tìm thấy người dùng!", 300)
      user ->
        data_changes = %{
          time_reminded: if (!is_nil(time_reminded)) do
              NaiveDateTime.from_iso8601!(time_reminded)
              |> NaiveDateTime.truncate(:second)
            else 
              nil
            end
        } 
                     
        Ecto.Changeset.change(user, data_changes)
        |> Repo.update
        |> case do
          {:ok, updated_user} ->
            updated_user_map = Helper.get_user_map_from_struct(updated_user)
            RedisDB.update_user(updated_user_map)
            Helper.response_json_with_data(true, "Cập nhật thông tin người dùng thành công!", updated_user_map)

          _ -> Helper.response_json_message(false, "Không thể cập nhật thông tin!", 321)
        end
    end
    json conn, response
  end

  def change_password(conn, params) do
    user_id = conn.assigns.user.user_id
    old_password = params["old_password"]
    new_password = params["new_password"]

    response = Repo.get_by(User, id: user_id)
    |> case do
      nil -> Helper.response_json_message(false, "Không tìm thấy người dùng!", 300)

      user ->
        Argon2.verify_pass(old_password, user.password_hash)
        |> case do
          false -> Helper.response_json_message(false, "Sai tài khoản hoặc mật khẩu!", 282)
          true ->
            is_pass_password_length = validate_password_length(new_password)

            if is_pass_password_length do
              new_password_hash = Argon2.hash_pwd_salt(new_password)
              data_jwt = %{
                "user_id" => user_id,
                "role_id" => conn.assigns.user.role_id
              }

              {_, new_refresh_token, _} = Helper.create_token(data_jwt, :refresh_token)
              {_, new_access_token, access_exp} = Helper.create_token(data_jwt, :access_token)

              Ecto.Changeset.change(user, %{password_hash: new_password_hash, refresh_token: new_refresh_token})
              |> Repo.update
              |> case do
                {:ok, _} ->
                  res_data = %{
                    "access_token" => new_access_token,
                    "refresh_token" => new_refresh_token,
                    "access_exp" => access_exp
                  }
                  Helper.response_json_with_data(true, "Đổi mật khẩu thành công!", res_data)
                _ -> Helper.response_json_message(false, "Lỗi khi đổi mật khẩu")
              end
            else
              Helper.response_json_message(false, "Mật khẩu mới không được chấp nhận!", 282)
            end
        end
    end

    json conn, response
  end

  # def forgot_password(conn, params) do
  #   
  # end

  def add_firebase_token(conn, params) do
    user_id = conn.assigns.user.user_id
    firebase_token = params["firebase_token"]
    platform = params["platform"]

    res = %FirebaseToken{
      user_id: user_id,
      platform: platform,
      token: firebase_token
    }
    |> Repo.insert(on_conflict: :nothing)
    |> case do
      {:ok, _} -> Helper.response_json_message(true, "Thêm firebase token thành công!")
      _ -> Helper.response_json_message(false, "Thêm firebase token thất bại!", 303)
    end
    json conn, res
  end


  @spec validate_password_length(String.t()) :: boolean()
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
end

# Redis section for ref
        # overall_data = RedisDB.get_overall_data_for_user(type, user_id)
        # |> case do
        #   nil ->
        #     overall = Helper.aggregate_with_fields(query, keys)
        #     RedisDB.update_overall_data_for_user(type, user_id, overall)
        #     overall
        #   data -> data
        # end

        # household_overall_data = RedisDB.get_overall_data_for_admin("household")
        # |> case do
        #   nil ->
        #     count_household_user = User |> where([u], u.role_id == ^2) |> Repo.aggregate(:count)
        #     keys = ["kg_co2e_plastic_reduced", "kg_co2e_recycle_reduced", "kg_recycle_collected"]
        #     household_overall_data = Helper.aggregate_with_fields(OverallHouseholdContribution, keys) |> Map.put(:count_household, count_household_user)
        #     RedisDB.update_overall_data_for_admin("household", household_overall_data)
        #     household_overall_data
        #   data -> data
        # end

        # scraper_overall_data = RedisDB.get_overall_data_for_admin("scrap")
        # |> case do
        #   nil ->
        #     count_scraper_user = User |> where([u], u.role_id == ^3) |> Repo.aggregate(:count)
        #     keys = ["kg_co2e_reduced", "expense_reduced", "kg_collected"]
        #     scraper_overall_data = Helper.aggregate_with_fields(OverallScraperContribution, keys) |> Map.put(:count_scraper, count_scraper_user)
        #     RedisDB.update_overall_data_for_admin("scrap", scraper_overall_data)
        #     scraper_overall_data
        #   data -> data
        # end
