defmodule CecrUnwomen.Fcm.FcmStore do
  alias CecrUnwomen.Fcm.FcmToken
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: FcmStore)
  end

  # atom: {time_created, token}
  def init(_) do
    {:ok, {System.os_time(:second), nil}}
  end

  # {:reply, token, state} => token sẽ là kết quả mà người gọi nhận được
  def handle_call(:get_token, _, state) do
    time_now = System.os_time(:second)

    case state do
      # 1. nếu chưa có token => gen token mới
      {_, nil} ->
        %{
          "time_created" => time_new_created,
          "token" => token
        } = generate_token()

        {:reply, token, {time_new_created, token}}

      # 2. token hết hạn (3600s) => gen token mới
      {time_created, _} when time_created + 3600 < time_now ->
        %{
          "time_created" => time_new_created,
          "token" => token
        } = generate_token()

        {:reply, token, {time_new_created, token}}

      # 3. đã có token trong state => lấy từ state ra
      {time_created, token} -> {:reply, token, {time_created, token}}
    end
  end

  def handle_cast(:refresh_token, _) do
    %{
      "time_created" => time_created,
      "token" => token
    } = FcmToken.load_credentials |> FcmToken.fetch_token
    {:noreply, {time_created, token}}
  end

  def generate_token() do
    FcmToken.load_credentials |> FcmToken.fetch_token
  end
end
