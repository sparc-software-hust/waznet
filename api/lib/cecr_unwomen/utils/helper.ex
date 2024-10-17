defmodule CecrUnwomen.Utils.Helper do
  def validate_token(token) do
    Application.get_env(:cecr_unwomen, CecrUnwomenWeb.Endpoint)[:secret_key_base]
    # phải có from_oct để key không bị đổi thành bytes
    |> JOSE.JWK.from_oct
    |> JOSE.JWT.verify(token)
    # nếu token được validate -> matching : {true, payload, jws}
  end
	
	def response_json_message(success, message) do
		%{success: success, message: message}
	end
	
	def response_json_message(success, message, error_code) do
		%{success: success, message: message, error_code: error_code}
	end
end
