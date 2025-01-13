defmodule CecrUnwomen.Fcm.FcmToken do
  @default_url "https://www.googleapis.com/oauth2/v4/token"
  @default_scopes "https://www.googleapis.com/auth/cloud-platform"
  
  alias CecrUnwomen. { Utils.ApiHandler }

  def load_credentials() do
    is_prod = System.get_env("MIX_ENV") == "prod" || false
    path_credentials = if is_prod do
      :code.priv_dir(:cecr_unwomen)
      |> Path.join("/certs/cecr-unwomen-fcm.json")
    else
      "priv/certs/cecr-unwomen-fcm.json"
    end
    credentials = path_credentials
    |> File.read!()
    |> Jason.decode!()
    |> Map.take(["private_key", "client_email"])
    {:service_account, credentials}
  end

# {:service_account, credentials}
  def fetch_token({:service_account, credentials}) do
    jwt = generate_jwt_signature(credentials)
    headers = [{"Content-type", "application/x-www-form-urlencoded"}]
    grant_type = "urn:ietf:params:oauth:grant-type:jwt-bearer"
    body = "grant_type=#{grant_type}&assertion=#{jwt}"
    payload = ApiHandler.post(@default_url, body, headers, [])
    time_created = System.os_time(:second)

    if (payload["success"]) do
      token = payload["response"]["access_token"]
      %{
        "success" => true,
        "token" => token,
        "time_created" => time_created
      }
    else
      %{
        "success" => false,
        "token" => nil,
        "time_created" => time_created
      }
    end
  end

  def generate_jwt_signature(%{"private_key" => private_key, "client_email" => client_email}) do
    unix_time = System.os_time(:second)
    jwk = JOSE.JWK.from_pem(private_key)

    header = %{
      "alg" => "RS256",
      "typ" => "JWT"
    }
    claims = %{
      "iss" => client_email,
      "aud" => @default_url,
      "scope" => @default_scopes,
      "exp" => unix_time + 3600,
      "iat" => unix_time,
    }
    JOSE.JWT.sign(jwk, header, claims) |> JOSE.JWS.compact() |> elem(1)
  end
end

# custom sau
# header_encode = %{
#   "alg" => "RS256",
#   "typ" => "JWT"
# } |> Poison.encode!() |> Base.encode64(padding: false)

# claims_encode = %{
#   "iss" => client_email,
#   "aud" => @default_url,
#   "scope" => @default_scopes,
#   "exp" => unix_time + 3600,
#   "iat" => unix_time,
# } |> Poison.encode!() |> Base.encode64(padding: false)

# signing_input = "#{header_encode}.#{claims_encode}" |> IO.inspect
# jwt_signature = :crypto.sign()

# header = %{"alg" => "RS256", "typ" => "JWT"}
# claims = %{
#   "iss" => client_email,
#   "aud" => @default_url,
#   "scope" => @default_scopes,
#   "exp" => unix_time + 3600,
#   "iat" => unix_time,
# }
