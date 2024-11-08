defmodule CecrUnwomen.Workers.ConstantWorker do
  use GenServer
  alias CecrUnwomen.{Repo, RedisDB}
  alias CecrUnwomenWeb.Models.{ ScrapConstantFactor, HouseholdConstantFactor }

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: ConstantWorker)
  end

  def init(_) do
    scrap_factors =
      RedisDB.get_all_factors_by_type("scrap")
      |> case do
        nil -> 
          Repo.all(ScrapConstantFactor) |> Enum.each(&RedisDB.update_factor_by_type(&1, "scrap"))
          RedisDB.get_all_factors_by_type("scrap")
        factors -> factors
      end
      |> Enum.reduce(%{}, fn f, acc -> Map.put(acc, String.to_integer(f["id"]), String.to_float(f["value"])) end)

    household_factors =
      RedisDB.get_all_factors_by_type("household")
      |> case do
        nil ->
          Repo.all(HouseholdConstantFactor) |> Enum.each(&RedisDB.update_factor_by_type(&1, "household"))
          RedisDB.get_all_factors_by_type("household")
        factors -> factors
      end
      |> Enum.reduce(%{}, fn f, acc -> Map.put(acc, String.to_integer(f["id"]), String.to_float(f["value"])) end)

    {:ok, {scrap_factors, household_factors}}
  end

  def handle_call(:get_scrap_factors, _, {sf, _} = state) do
    {:reply, sf, state}
  end

  def handle_call(:get_household_factors, _, {_, hf} = state) do
    {:reply, hf, state}
  end
end
