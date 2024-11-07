defmodule CecrUnwomenWeb.ContributionController do
  use CecrUnwomenWeb, :controller
  import Ecto.Query

  alias CecrUnwomenWeb.Models.{
    ScraperContribution,
    ScrapConstantFactor,
    HouseholdContribution,
    HouseholdConstantFactor,
    OverallScraperContribution,
    OverallHouseholdContribution
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
          overall = Enum.reduce(data_entry, %{ kgco2e: 0, expense_reduced: 0, kg: 0 }, fn d, acc ->
            %{"factor_id" => factor_id, "quantity" => quantity} = d

            %ScraperContribution{
              date: date,
              user_id: user_id,
              factor_id: factor_id,
              quantity: :erlang.float(quantity)
            }
            |> Repo.insert()

            Map.update!(acc, :kg, &(&1 + quantity))
            |> Map.update!(:kgco2e, &(&1 + constant_value[factor_id] * quantity))
          end)

          overall = Map.update!(overall, :expense_reduced, &(&1 + constant_value[4] * overall.kg))
          |> Enum.map(fn {k, v} -> {k, Float.round(v, 2)} end)
          |> Enum.into(%{})

          %OverallScraperContribution{
            date: date,
            user_id: user_id,
            kg_co2e_reduced: overall.kgco2e,
            kg_collected: overall.kg,
            expense_reduced: overall.expense_reduced
          } |> Repo.insert
        end)
        |> case do
          {:ok, _} -> Helper.response_json_message(true, "Nhập thông tin thành công!")
          _ -> Helper.response_json_message(false, "Có lỗi xảy ra", 406)
        end

      role_id == 2 ->
        constant_value = GenServer.call(ConstantWorker, :get_household_factors)

        Repo.transaction(fn ->
          overall = Enum.reduce(data_entry, %{ kgco2e_plastic: 0, kgco2e_recycle: 0, kg_recycle_collected: 0 }, fn d, acc ->
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
              Map.update!(acc, :kgco2e_plastic, &(&1 + constant_value[factor_id] * quantity))
            else
              Map.update!(acc, :kg_recycle_collected, &(&1 + quantity))
              |> Map.update!(:kgco2e_recycle, &(&1 + constant_value[factor_id] * quantity))
            end
          end)
          |> Enum.map(fn {k, v} -> {k, Float.round(v, 2)} end)
          |> Enum.into(%{})

          %OverallHouseholdContribution{
            date: date,
            user_id: user_id,
            kg_co2e_plastic_reduced: overall.kgco2e_plastic,
            kg_co2e_recycle_reduced: overall.kgco2e_recycle,
            kg_recycle_collected: overall.kg_recycle_collected
          } |> Repo.insert
        end)
        |> case do
          {:ok, _} -> Helper.response_json_message(true, "Nhập thông tin thành công!")
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
end
