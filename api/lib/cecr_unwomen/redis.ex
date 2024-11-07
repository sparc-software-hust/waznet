defmodule CecrUnwomen.RedisDB do

  # @spec update_user(%{key: any()}) :: none()
  def update_user(user) do
    key = "user:#{user.id}"
    user_encode = encode_data(user)
    insert_command = ["HSET", key, "user", user_encode]
    Redix.command(:redix, insert_command)
    # expire_command = ["EXPIRE", key, ]
    # Redix.pipeline(:redix, [insert_command, expire_command])
  end

  @spec get_user(String.t()) :: %{key: any()} | nil
  def get_user(user_id) do
    key = "user:#{user_id}"
    get_command = ["HGET", key, "user"]
    Redix.command(:redix, get_command)
    |> case do
      {:ok, encoded_user} -> decode_data(encoded_user)
      _ -> nil
    end
  end

  def update_scrap_factor(factor) do
    key = "scrap_factor:#{factor.id}"
    set_command = [
      "HSET", key,
      "id", factor.id,
      "name", factor.name,
      "value", factor.value,
      "unit", factor.unit
    ]
    Redix.command(:redix, set_command)
  end

  def get_all_scrap_factors() do
    {:ok, keys} = Redix.command(:redix, ["KEYS", "scrap_factor:*"])
    Enum.map(keys, fn key ->
      {:ok, data} = Redix.command(:redix, ["HGETALL", key])
      Enum.chunk_every(data, 2) |> Enum.map(&List.to_tuple/1) |> Enum.into(%{})
    end)
  end

  def update_household_factor(factor) do
    key = "household_factor:#{factor.id}"
    set_command = [
      "HSET", key,
      "id", factor.id,
      "name", factor.name,
      "value", factor.value,
      "unit", factor.unit
    ]
    Redix.command(:redix, set_command)
  end


  def get_all_household_factors() do
    {:ok, keys} = Redix.command(:redix, ["KEYS", "household_factor:*"])
    Enum.map(keys, fn key ->
      {:ok, data} = Redix.command(:redix, ["HGETALL", key])
      Enum.chunk_every(data, 2) |> Enum.map(&List.to_tuple/1) |> Enum.into(%{})
    end)
  end

  def encode_data(nil) do "NULL" end
  def encode_data(data) do Jason.encode!(data) end
  def decode_data(nil) do nil end
  def decode_data(data) do Jason.decode!(data) end
end
