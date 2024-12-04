defmodule CecrUnwomen.Utils.Helper do
  alias CecrUnwomen.Repo

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
            type = jwt.fields["type"]

            data = %{}
            |> Map.put(:user_id, user_id)
            |> Map.put(:role_id, role_id)
            |> Map.put(:type, type)

            data = if type == "refresh" do
              data
              |> Map.put(:exp, expires_in)
              |> Map.put(:refresh_token, token)
            else
              data
            end

            {:valid_token, data}
        end

      _ -> :invalid_token
    end
  end

  @spec create_token(map(), atom(), integer()) :: {atom(), String.t(), integer()}
  def create_token(claims, token_type, exp \\ 0) do
    # exp != 0 => giữ nguyên exp cho refresh token
    secret_key = Application.get_env(:cecr_unwomen, CecrUnwomenWeb.Endpoint)[:secret_key_base]

    jwk = %{
      "kty" => "oct",
      "k" => :jose_base64url.encode(secret_key)
    }

    jws = %{"alg" => "HS256"}

    iat = DateTime.utc_now() |> DateTime.to_unix(:second)

    exp =
      case token_type do
        :access_token -> iat + 300
        :refresh_token -> if exp != 0, do: exp, else: iat + 63_072_000
        _ -> iat
      end

    type =
      case token_type do
        :access_token -> "access"
        :refresh_token -> "refresh"
        _ -> "blacklist"
      end

    jwt =
      %{
        "iss" => "cecr_unwomen",
        "iat" => iat,
        "exp" => exp,
        "type" => type
      }
      |> Map.merge(claims)

    token = JOSE.JWT.sign(jwk, jws, jwt)
    |> JOSE.JWS.compact()
    |> elem(1)

    {token_type, token, exp}
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

  def get_user_map_from_struct(user) do
    Map.from_struct(user)
    |> Map.drop([:refresh_token, :inserted_at, :updated_at, :role, :__meta__, :password_hash])
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Enum.into(%{})
  end

  def aggregate_with_fields(query, fields) do
    Enum.reduce(fields, %{}, fn key, acc -> 
      key_atom = String.to_atom(key)
      count_value = Repo.aggregate(query, :sum, key_atom)
      Map.put(acc, key_atom, count_value)
    end)
  end

  def get_vietnam_date_today() do
    # TODO: change correct time
    NaiveDateTime.utc_now()
    |> NaiveDateTime.add(7 * 3600, :second)
    # |> NaiveDateTime.add(-10, :day)
    |> NaiveDateTime.to_date
  end
end
