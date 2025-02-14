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
  
  def get_local_time_now_string(timezone) do
    #Asia/Ho_Chi_Minh
    DateTime.now!(timezone)
    |> Calendar.strftime("%d/%m/%Y")
  end
  
  def fold_fcm_token(map, extra_fields \\ %{}) do
    map
    |> Enum.reduce(%{}, fn item, acc ->
      user_id = item["user_id"]
      token = item["token"]
      
      base_map = Map.merge(
        %{
          "user_id" => user_id,
          "tokens" => [token]
        },
        extra_fields
      )

      Map.update(acc, user_id, base_map, fn existing ->
        Map.update(existing, "tokens", [token], fn tokens -> tokens ++ [token] end)
      end)
    end)
    |> Map.values()
  end
  
  def unsign_vietnamese(text, opt \\ [downcase: true]) do
    downcase = Keyword.get(opt, :downcase, true)
    text = if downcase do
      String.downcase(text)
    else
      text
      |> String.replace(["À","Á","Ạ","Ả","Ã","Â","Ầ","Ấ","Ậ","Ẩ","Ẫ","Ă","Ằ","Ắ","Ặ","Ẳ","Ẵ"], "A")
      |> String.replace(["È","É","Ẹ","Ẻ","Ẽ","Ê","Ề","Ế","Ệ","Ể","Ễ"], "E")
      |> String.replace(["Ì", "Í","Ị","Ỉ","Ĩ"], "I")
      |> String.replace(["Ò","Ó","Ọ","Ỏ","Õ","Ô","Ồ","Ố","Ộ","Ổ","Ỗ","Ơ","Ờ","Ớ","Ợ","Ở"], "O")
      |> String.replace(["Ù","Ú","Ụ","Ủ","Ũ","Ư","Ừ","Ứ","Ự","Ử","Ữ"], "U")
      |> String.replace(["Ỳ","Ý","Ỵ","Ỷ","Ỹ"], "Y")
      |> String.replace("Đ", "D")
    end
    text
    |> String.replace(["à","á","ạ","ả","ã","â","ầ","ấ","ậ","ẩ","ẫ","ă","ằ","ắ","ặ","ẳ","ẵ"], "a")
    |> String.replace(["è","é","ẹ","ẻ","ẽ","ê","ề","ế","ệ","ể","ễ"], "e")
    |> String.replace(["ì", "í","ị","ỉ","ĩ"], "i")
    |> String.replace(["ò","ó","ọ","ỏ","õ","ô","ồ","ố","ộ","ổ","ỗ","ơ","ờ","ớ","ợ","ở"], "o")
    |> String.replace(["ù","ú","ụ","ủ","ũ","ư","ừ","ứ","ự","ử","ữ"], "u")
    |> String.replace(["ỳ","ý","ỵ","ỷ","ỹ"], "y")
    |> String.replace("đ", "d")
  end
end
