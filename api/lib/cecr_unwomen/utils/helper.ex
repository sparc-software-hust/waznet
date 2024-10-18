defmodule CecrUnwomen.Utils.Helper do
  def validate_token(token) do
    Application.get_env(:cecr_unwomen, CecrUnwomenWeb.Endpoint)[:secret_key_base]
    # phải có from_oct để key không bị đổi thành bytes
    |> JOSE.JWK.from_oct()
    |> JOSE.JWT.verify(token)
    |> case do
      {true, jwt, _} ->
        expires_in = jwt.fields["exp"]
        now = DateTime.utc_now() |> DateTime.to_unix(:second)

        case now > expires_in do
          true -> :invalid_token
          false ->
            user_id = jwt.fields["user_id"]
            role_id = jwt.fields["role_id"]
            data = %{}
              |> Map.put(:user_id, user_id)
              |> Map.put(:role_id, role_id)
            {:valid_token, data}
        end

      _ -> :invalid_token
    end
  end

  def response_json_message(success, message) do
    %{success: success, message: message}
  end

  def response_json_with_data(success, message, data) do
    %{success: success, message: message, data: data}
  end

  def response_json_message(success, message, error_code) do
    %{success: success, message: message, error_code: error_code}
  end
end
