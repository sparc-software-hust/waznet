defmodule CecrUnwomenWeb.UploadController do
  alias CecrUnwomen.Utils.Helper
  use CecrUnwomenWeb, :controller

  def upload_avatar(conn, params) do
    user_id = conn.assigns.user.user_id
    data_image = params["data"]
    content_type = data_image.content_type
    path = data_image.path
    file_name = data_image.filename

    can_serve = content_type != nil && path != nil && file_name != nil
    res = if (!can_serve) do
      Helper.response_json_message(false, "Ảnh không hợp lệ!", 300)
    else
      extension = Path.extname(file_name)
      is_image = extension |> String.downcase |> String.contains?(["jpg", "png", "heic", "jpeg"])

      cond do
        !is_image -> Helper.response_json_message(false, "Bạn upload không đúng định dạng!", 402)
        true ->
					env = System.get_env("MIX_ENV") || "dev"
					static_dir = config_static_dir(env)
          image_avatar_name = "#{user_id}_avatar#{extension}"
          destination = "#{static_dir}/#{image_avatar_name}"
          File.cp(path, destination)
          |> case do
            :ok ->
              # save to db and redis
              Helper.response_json_message(true, "Upload avatar thành công")
            {:error, err} ->
              IO.inspect(err, label: "e")
              Helper.response_json_message(false, "Không thể lưu ảnh!", 402)
          end
        end
    end
    json conn, res
  end
	
	def config_static_dir("prod") do
		static_dir = "/app/api/static"
		File.dir?(static_dir)
		|> case do
			false -> 
				File.mkdir(static_dir)
				static_dir
			true -> static_dir
		end
	end
	
	def config_static_dir("dev") do
		{:ok, dir} = File.cwd
		static_dir = "#{dir}/static"
		File.dir?(static_dir)
		|> case do
			false -> 
				File.mkdir(static_dir)
				static_dir
			true -> static_dir
		end
	end
end
