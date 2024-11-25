defmodule CecrUnwomenWeb.ContributionController do
  use CecrUnwomenWeb, :controller
  import Ecto.Query

  alias CecrUnwomenWeb.Models.{
    User,
    ScraperContribution,
    HouseholdContribution,
    OverallScraperContribution,
    OverallHouseholdContribution,
    HouseholdConstantFactor,
    ScrapConstantFactor
  }

  alias CecrUnwomen.{Utils.Helper, Repo}

  def contribute_data(conn, params) do
    user_id = conn.assigns.user.user_id
    role_id = conn.assigns.user.role_id
    date = params["date"] |> Date.from_iso8601!()
    data_entry = params["data_entry"] || []

    res = cond do
      Enum.empty?(data_entry) -> Helper.response_json_message(false, "Không có thông tin để nhập", 406)

      role_id == 3 ->
        constant_value = GenServer.call(ConstantWorker, :get_scrap_factors)

        Repo.transaction(fn ->
          overall = Enum.reduce(data_entry, %{ kg_co2e_reduced: 0, expense_reduced: 0, kg_collected: 0 }, fn d, acc ->
            %{"factor_id" => factor_id, "quantity" => quantity} = d

            %ScraperContribution{
              date: date,
              user_id: user_id,
              factor_id: factor_id,
              quantity: :erlang.float(quantity)
            }
            |> Repo.insert()

            Map.update!(acc, :kg_collected, &(&1 + quantity))
            |> Map.update!(:kg_co2e_reduced, &(&1 + constant_value[factor_id] * quantity))
          end)

          overall = Map.update!(overall, :expense_reduced, &(&1 + constant_value[4] * overall.kg_collected))
          |> Enum.map(fn {k, v} -> {k, Float.round(v, 2)} end)
          |> Enum.into(%{})
          # TODO: check with float.round(0, 2)

          %OverallScraperContribution{
            date: date,
            user_id: user_id,
            kg_co2e_reduced: overall.kg_co2e_reduced,
            kg_collected: overall.kg_collected,
            expense_reduced: overall.expense_reduced
          } |> Repo.insert

          # TODO: set key based on overall
          keys = ["kg_co2e_reduced", "expense_reduced", "kg_collected"]
          Helper.aggregate_with_fields(OverallScraperContribution, keys)
        end)
        |> case do
          {:ok, overall_data} -> Helper.response_json_with_data(true, "Nhập thông tin thành công!", overall_data)
          _ -> Helper.response_json_message(false, "Có lỗi xảy ra", 406)
        end

      role_id == 2 ->
        constant_value = GenServer.call(ConstantWorker, :get_household_factors)

        Repo.transaction(fn ->
          overall = Enum.reduce(data_entry, %{ kg_co2e_plastic_reduced: 0, kg_co2e_recycle_reduced: 0, kg_recycle_collected: 0 }, fn d, acc ->
            %{"factor_id" => factor_id, "quantity" => quantity} = d
            # với factor_id từ 1 đến 4, là số lượng túi/giấy/ống hút => phải là int
            quantity = if factor_id <= 4, do: round(quantity), else: quantity

            %HouseholdContribution{
              date: date,
              user_id: user_id,
              factor_id: factor_id,
              quantity: :erlang.float(quantity)
            }
            |> Repo.insert()

            if (factor_id <= 4) do
              Map.update!(acc, :kg_co2e_plastic_reduced, &(&1 + constant_value[factor_id] * quantity))
            else
              Map.update!(acc, :kg_recycle_collected, &(&1 + quantity))
              |> Map.update!(:kg_co2e_recycle_reduced, &(&1 + constant_value[factor_id] * quantity))
            end
          end)
          |> Enum.map(fn {k, v} -> {k, Float.round(v, 2)} end)
          |> Enum.into(%{})

          %OverallHouseholdContribution{
            date: date,
            user_id: user_id,
            kg_co2e_plastic_reduced: overall.kg_co2e_plastic_reduced,
            kg_co2e_recycle_reduced: overall.kg_co2e_recycle_reduced,
            kg_recycle_collected: overall.kg_recycle_collected
          } |> Repo.insert

          keys = ["kg_co2e_plastic_reduced", "kg_co2e_recycle_reduced", "kg_recycle_collected"]
          Helper.aggregate_with_fields(OverallHouseholdContribution, keys)
        end)
        |> case do
          {:ok, overall_data} -> Helper.response_json_with_data(true, "Nhập thông tin thành công!", overall_data)
          _ -> Helper.response_json_message(false, "Có lỗi xảy ra", 406)
        end

      true -> Helper.response_json_message(false, "Có lỗi xảy ra khi thực hiện nhập thông tin!", 406)
    end

    json(conn, res)
  end

  def edit_factor_quantity(conn, params) do
    user_id = conn.assigns.user.user_id
    factor_id = params["factor_id"] || 0
    quantity = params["quantity"] || 0
    type = params["type"] || "scrap"
    date = params["date"] |> Date.from_iso8601!()

    model = if type == "scrap", do: ScraperContribution, else: HouseholdContribution

    res =
      model
      |> where([m], m.user_id == ^user_id and m.factor_id == ^factor_id and m.date == ^date)
      |> select([m], m)
      |> Repo.one()
      |> case do
        nil ->
          Helper.response_json_message(false, "Bạn chưa nhập thông tin ngày hôm nay", 407)

        entry ->
          maximum_time_can_edit = entry.inserted_at |> NaiveDateTime.add(86400)
          can_edit = NaiveDateTime.utc_now() |> NaiveDateTime.before?(maximum_time_can_edit)

          if can_edit do
            data_changes = %{factor_id: factor_id, quantity: :erlang.float(quantity)}

            Ecto.Changeset.change(entry, data_changes)
            |> Repo.update()
            |> case do
              {:ok, updated_entry} ->
                key_drop =
                  if type == "scrap", do: :scrap_constant_factor, else: :household_constant_factor

                entry =
                  Map.from_struct(updated_entry)
                  |> Map.drop([:__meta__, :user, key_drop])
                  |> Enum.into(%{})

                Helper.response_json_with_data(true, "Cập nhật số liệu thành công!", entry)

              _ ->
                Helper.response_json_message(false, "Không thể update thông tin!", 407)
            end
          else
            Helper.response_json_message(false, "Không thể thay đổi thông tin sau 24h!", 408)
          end
      end

    json(conn, res)
  end

  def get_contribution(conn, params) do
    user_id_request = conn.assigns.user.user_id
    role_id_request = conn.assigns.user.role_id

    # business case
    # 1. admin query => k care user => check role_id
    # 2. user query => query chinh xac user => check role_id

    type = params["type"] || "scrap"
    limit = String.to_integer(params["limit"])
    page = String.to_integer(params["page"])
    offset = limit * page

    from = params["from"] |> Date.from_iso8601!()
    to = params["to"] |> Date.from_iso8601!()
    date_diff = Date.diff(from, to)

    is_admin = role_id_request == 1
    model = cond do
      is_admin -> if type == "scrap", do: ScraperContribution, else: HouseholdContribution
      role_id_request == 2 -> HouseholdContribution
      true -> ScraperContribution
    end

    res =
      cond do
        date_diff != 0 ->
          pre_query = if (is_admin) do
            model |> where([m], m.date >= ^from and m.date <= ^to)
          else
            model |> where([m], m.date >= ^from and m.date <= ^to and m.user_id == ^user_id_request)
          end
          data = pre_query
            |> order_by([m], desc: m.date)
            |> offset(^offset)
            |> limit(^limit)
            |> select([m], %{
              id: m.id,
              user_id: m.user_id,
              date: m.date,
              factor_id: m.factor_id,
              quantity: m.quantity,
              inserted_at: m.inserted_at
            })
            |> Repo.all()

          Helper.response_json_with_data(true, "Lấy dữ liệu thành công!", data)

        date_diff == 0 ->
          pre_query = if (is_admin) do
            model |> where([m], m.date == ^from)
          else
            model |> where([m], m.date == ^from and m.user_id == ^user_id_request)
          end
          data = pre_query
            |> order_by([m], desc: m.date)
            |> offset(^offset)
            |> limit(^limit)
            |> select([m], %{
              user_id: m.user_id,
              date: m.date,
              factor_id: m.factor_id,
              quantity: m.quantity,
              inserted_at: m.inserted_at
            })
            |> Repo.all()

          Helper.response_json_with_data(true, "Lấy dữ liệu thành công!", data)

        true -> Helper.response_json_message(false, "Có lỗi xảy ra!", 405)
      end

    json(conn, res)
  end

  def get_overall_data(conn, _) do
    # check role id
    # neu admin lay nhung data sau:
    # - scraper: total user, total kg collected, total kgco2 recycle, expense reduced
    # - household: total user, total kg recycled collected, total kgco2 recycle, plastic reduced
    # - data co2e recycled in 1 week from today
    # - household contribution today
    # - scraper contribution today
    user_id = conn.assigns.user.user_id
    role_id = conn.assigns.user.role_id
    res = cond do
      role_id != 1 ->
        model_overall = if role_id == 2, do: OverallHouseholdContribution, else: OverallScraperContribution
        keys = if role_id == 2, do: ["kg_co2e_plastic_reduced", "kg_co2e_recycle_reduced", "kg_recycle_collected"],
          else: ["kg_co2e_reduced", "expense_reduced", "kg_collected"]
        query = model_overall |> where([m], m.user_id == ^user_id)

        count_days_joined = User |> where([u], u.id == ^user_id) |> select([u], u.inserted_at) |> Repo.one
          |> case do
            nil -> 0
            inserted_at -> NaiveDateTime.utc_now() |> NaiveDateTime.diff(inserted_at, :day)
          end

        today = Helper.get_vietnam_date_today()
        {start_month, end_month} = {Date.beginning_of_month(today), Date.end_of_month(today)}

        sum_factors = if role_id == 2 do
          HouseholdContribution
          |> join(:inner, [hc], hcf in HouseholdConstantFactor, on: hc.factor_id == hcf.id)
          |> where([hc], hc.user_id == ^user_id and hc.date >= ^start_month and hc.date <= ^end_month)
          |> group_by([hc, hcf], [hc.factor_id, hcf.name])
        else
          ScraperContribution
          |> join(:inner, [hc], scf in ScrapConstantFactor, on: hc.factor_id == scf.id)
          |> where([hc], hc.user_id == ^user_id and hc.date >= ^start_month and hc.date <= ^end_month)
          |> group_by([hc, scf], [hc.factor_id, scf.name])
        end
        |> order_by([hc], asc: hc.factor_id)
        |> select([hc, f], %{
          factor_id: hc.factor_id,
          factor_name: f.name,
          quantity: sum(hc.quantity)
        })
        |> Repo.all

        overall = Helper.aggregate_with_fields(query, keys)
          |> Map.put(:days_joined, count_days_joined)
          |> Map.put(:sum_factors, sum_factors)

        Helper.response_json_with_data(true, "Lấy dữ liệu thành công", overall)

      role_id == 1 ->
        keys = ["kg_co2e_plastic_reduced", "kg_co2e_recycle_reduced", "kg_recycle_collected"]
        count_household_user = User |> where([u], u.role_id == ^2) |> Repo.aggregate(:count)
        household_overall_data = Helper.aggregate_with_fields(OverallHouseholdContribution, keys) |> Map.put(:count_household, count_household_user)

        count_scraper_user = User |> where([u], u.role_id == ^3) |> Repo.aggregate(:count)
        keys = ["kg_co2e_reduced", "expense_reduced", "kg_collected"]
        scraper_overall_data = Helper.aggregate_with_fields(OverallScraperContribution, keys) |> Map.put(:count_scraper, count_scraper_user)

        {overall_scrapers_today, overall_households_today} = get_users_contribution_today()
        {scraper_total_kgco2e_seven_days, household_total_kgco2e_seven_days} = get_total_kgco2e_seven_days()

        overall = %{
          household_overall_data:
            household_overall_data
            |> Map.put(:overall_households_today, overall_households_today)
            |> Map.put(:household_total_kgco2e_seven_days, household_total_kgco2e_seven_days),

          scraper_overall_data: scraper_overall_data
            |> Map.put(:overall_scrapers_today, overall_scrapers_today)
            |> Map.put(:scraper_total_kgco2e_seven_days, scraper_total_kgco2e_seven_days)
        }
        Helper.response_json_with_data(true, "Lấy dữ liệu thành công", overall)
      true ->
        Helper.response_json_message(false, "Bạn không có đủ quyền thực hiện thao tác!", 402)
    end
    json conn, res
  end

  defp get_total_kgco2e_seven_days() do
    to = "2024-11-11" |> Date.from_iso8601!()
    # to = NaiveDateTime.local_now()
    #   |> NaiveDateTime.add(7 * 3600, :second)
    #   |> NaiveDateTime.to_date

    from = Date.add(to, -7)

    household_total_kgco2e_seven_days = OverallHouseholdContribution
      |> where([osc], osc.date >= ^from and osc.date <= ^to)
      |> group_by([m], m.date)
      |> order_by([m], desc: m.date)
      |> select([m], %{
        date: m.date,
        total_kg_co2e: sum(m.kg_co2e_plastic_reduced) + sum(m.kg_co2e_recycle_reduced)
      })
      |> Repo.all()

    scraper_total_kgco2e_seven_days = OverallScraperContribution
      |> where([osc], osc.date >= ^from and osc.date <= ^to)
      |> group_by([m], m.date)
      |> order_by([m], desc: m.date)
      |> select([m], %{
        date: m.date,
        total_kg_co2e: sum(m.kg_co2e_reduced)
      })
      |> Repo.all()

    {scraper_total_kgco2e_seven_days, household_total_kgco2e_seven_days}
  end

  defp get_users_contribution_today(limit \\ 50, page \\ 0) do
    offset = limit * page

    current_day = "2024-11-08" |> Date.from_iso8601!()
    # current_day = NaiveDateTime.local_now()
    #   |> NaiveDateTime.add(7 * 3600, :second)
    #   |> NaiveDateTime.to_date

    overall_scrapers_today = OverallScraperContribution
      |> join(:left, [osc], u in User, on: u.id == osc.user_id)
      |> where([osc], osc.date == ^current_day)
      |> order_by([osc], desc: :date)
      |> offset(^offset)
      |> limit(^limit)
      |> select([osc, u], %{
        id: osc.id,
        kg_co2e_reduced: osc.kg_co2e_reduced,
        expense_reduced: osc.expense_reduced,
        kg_collected: osc.kg_collected,
        user_id: osc.user_id,
        avatar_url: u.avatar_url,
        inserted_at: osc.inserted_at,
        first_name: u.first_name,
        last_name: u.last_name
      })
      |> Repo.all

    overall_households_today = OverallHouseholdContribution
      |> join(:left, [ohc], u in User, on: u.id == ohc.user_id)
      |> where([ohc], ohc.date == ^current_day)
      |> order_by([ohc], desc: :date)
      |> offset(^offset)
      |> limit(^limit)
      |> select([ohc, u], %{
        id: ohc.id,
        kg_co2e_plastic_reduced: ohc.kg_co2e_plastic_reduced,
        kg_co2e_recycle_reduced: ohc.kg_co2e_recycle_reduced,
        kg_recycle_collected: ohc.kg_recycle_collected,
        inserted_at: ohc.inserted_at,
        user_id: ohc.user_id,
        avatar_url: u.avatar_url,
        first_name: u.first_name,
        last_name: u.last_name
      })
      |> Repo.all

    {overall_scrapers_today, overall_households_today}
  end

end
