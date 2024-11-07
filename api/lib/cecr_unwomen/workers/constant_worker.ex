defmodule CecrUnwomen.Workers.ConstantWorker do
  use GenServer
  alias CecrUnwomen.{Repo, RedisDB}
  alias CecrUnwomenWeb.Models.{ ScrapConstantFactor, HouseholdConstantFactor }

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: ConstantWorker)
  end

  def init(_) do
    scrap_factors =
      RedisDB.get_all_scrap_factors
      |> case do
        [] -> Repo.all(ScrapConstantFactor) |> Enum.each(&RedisDB.update_scrap_factor(&1))
        factors -> factors
      end
      |> Enum.reduce(%{}, fn f, acc -> Map.put(acc, String.to_integer(f["id"]), String.to_float(f["value"])) end)

    household_factors =
      RedisDB.get_all_household_factors
      |> case do
        [] -> Repo.all(HouseholdConstantFactor) |> Enum.each(&RedisDB.update_household_factor(&1))
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
