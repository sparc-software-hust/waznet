defmodule CecrUnwomenWeb.UploadController do
  alias CecrUnwomenWeb.Models.User
  alias CecrUnwomen.{Utils.Helper, Repo, RedisDB}
  use CecrUnwomenWeb, :controller

  def upload_avatar(conn, params) do
    user_id = conn.assigns.user.user_id
    data_image = params["data"]
    content_type = data_image.content_type
    path = data_image.path
    file_name = data_image.filename

    can_serve = content_type != nil && path != nil && file_name != nil

    res =
      if !can_serve do
        Helper.response_json_message(false, "Ảnh không hợp lệ!", 300)
      else
        extension = Path.extname(file_name)

        is_image =
          extension
          |> String.downcase()
          |> String.contains?(["jpg", "png", "heic", "jpeg", "tiff"])

        cond do
          !is_image -> Helper.response_json_message(false, "Bạn upload không đúng định dạng!", 402)

          true ->
            env = System.get_env("MIX_ENV") || "dev"
            {new_path, new_extension} = format_image_to_jpg(path)
            static_dir = config_static_dir(env)
            image_avatar_name = "#{user_id}_avatar#{new_extension}"
            destination = "#{static_dir}/#{image_avatar_name}"

            File.cp(new_path, destination)
            |> case do
              :ok -> update_user_in_db(user_id, image_avatar_name)

              {:error, err} ->
                IO.inspect(err, label: "e")
                Helper.response_json_message(false, "Không thể lưu ảnh!", 402)
            end
        end
      end

    json(conn, res)
  end

  def config_static_dir("prod") do
    static_dir = "/app/api/static"

    File.dir?(static_dir)
    |> case do
      false ->
        File.mkdir(static_dir)
        static_dir

      true ->
        static_dir
    end
  end

  def config_static_dir("dev") do
    {:ok, dir} = File.cwd()
    static_dir = "#{dir}/static"

    File.dir?(static_dir)
    |> case do
      false ->
        File.mkdir(static_dir)
        static_dir

      true ->
        static_dir
    end
  end

  def format_image_to_jpg(path) do
    # is_heic_or_tiff = ext |> String.downcase |> String.contains?(["heic", "tiff"])
    # if (is_heic_or_tiff) do
    image = Mogrify.open(path) |> Mogrify.format("jpg") |> Mogrify.resize_to_fill("200x200") |> Mogrify.save(in_place: true)
    {image.path, image.ext}
    # else
      # {path, ext}
    # end
  end

  def update_user_in_db(user_id, image_avatar_name) do
    Repo.get_by(User, id: user_id)
    |> case do
      nil -> Helper.response_json_message(false, "Không tìm thấy người dùng!", 402)
      user ->
        url = "http://#{System.get_env("HOST")}:#{System.get_env("PORT")}/upload/#{image_avatar_name}"
        Ecto.Changeset.change(user, %{avatar_url: url})
        |> Repo.update
        |> case do
          {:ok, updated_user} ->
            updated_user_map = Helper.get_user_map_from_struct(updated_user)
            RedisDB.update_user(updated_user_map)
            Helper.response_json_message(true, "Upload avatar thành công")

          _ -> Helper.response_json_message(false, "Có lỗi xảy ra! Vui lòng thử lại!", 403)
        end
    end
  end
end
