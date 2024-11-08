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

  def get_all_factors_by_type(type) do
    model = if type == "scrap", do: "scrap_factor", else: "household_factor"
    {:ok, keys} = Redix.command(:redix, ["KEYS", "#{model}:*"])
    cond do
      length(keys) == 0 -> nil
      true ->
        Enum.map(keys, fn key ->
          {:ok, data} = Redix.command(:redix, ["HGETALL", key])
          if (data != nil) do
            Enum.chunk_every(data, 2) |> Enum.map(&List.to_tuple/1) |> Enum.into(%{})
          end
        end)
    end
  end

  def update_factor_by_type(factor, type) do
    model = if type == "scrap", do: "scrap_factor", else: "household_factor"
    key = "#{model}:#{factor.id}"
    set_command = [
      "HSET", key,
      "id", factor.id,
      "name", factor.name,
      "value", factor.value,
      "unit", factor.unit
    ]
    Redix.command(:redix, set_command)
  end

  def update_overall_data_for_admin(type, data) do
    # scraper: number of users, co2_reduced_recycle, expense_reduced
    # household: number of users, co2_reduced_recycle, co2_reduced_plastic
    key = if (type == "scrap"), do: "overall_data:all_scraper", else: "overall_data:all_household"
    set_command = Enum.reduce(data, ["HSET", key], fn {k, value}, acc -> acc ++ [to_string(k), value] end)
    Redix.command(:redix, set_command)
  end

  def get_overall_data_for_admin(type) do
    key = if (type == "scrap"), do: "overall_data:all_scraper", else: "overall_data:all_household"
    get_command = ["HGETALL", key]
    {:ok, data} = Redix.command(:redix, get_command)
    case data do
      [] -> nil
      _ -> Enum.chunk_every(data, 2) |> Enum.map(&List.to_tuple/1) |> Enum.into(%{})
    end
  end

  def get_overall_data_for_user(type, user_id) do
    key = if (type == "scrap"), do: "overall_data:scraper_#{user_id}", else: "overall_data:household_#{user_id}"
    get_command = ["HGETALL", key]
    {:ok, data} = Redix.command(:redix, get_command)
    case data do
      [] -> nil
      _ -> Enum.chunk_every(data, 2) |> Enum.map(&List.to_tuple/1) |> Enum.into(%{})
    end
  end

  def update_overall_data_for_user(type, user_id, data) do
    key = if (type == "scrap"), do: "overall_data:scraper_#{user_id}", else: "overall_data:household_#{user_id}"
    set_command = Enum.reduce(data, ["HSET", key], fn {k, value}, acc -> acc ++ [to_string(k), value] end)
    Redix.command(:redix, set_command)
  end


  def encode_data(nil) do "NULL" end
  def encode_data(data) do Jason.encode!(data) end
  def decode_data(nil) do nil end
  def decode_data(data) do Jason.decode!(data) end
end
