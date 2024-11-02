defmodule CecrUnwomenWeb.ContributionController do
  use CecrUnwomenWeb, :controller
  import Ecto.Query
  alias CecrUnwomenWeb.Models.{ ScraperContribution, ScrapConstantFactor, HouseholdContribution, HouseholdConstantFactor }
  alias CecrUnwomen.{Utils.Helper, Repo, RedisDB}

  def contribute_scrap_data(conn, params) do
    user_id = conn.assigns.user.user_id
    date = params["date"] |> Date.from_iso8601!
    data_entry = params["data_entry"] || []

    # RedisDB.get_all_scrap_factors()
    # |> case do
    #   [] -> Repo.all(ScrapConstantFactor) |> Enum.each(&RedisDB.update_scrap_factor(&1))
    #   factors -> factors
    # end

    res =
      if (Enum.empty?(data_entry)) do Helper.response_json_message(false, "Không có thông tin để nhập", 406)
      else
        Repo.transaction(fn ->
          Enum.each(data_entry, fn d ->
            %{"factor_id" => factor_id, "quantity" => quantity} = d
            %ScraperContribution{
              date: date,
              user_id: user_id,
              factor_id: factor_id,
              quantity: :erlang.float(quantity)
            } |> Repo.insert
          end)
        end)
        |> case do
          {:ok, _} -> Helper.response_json_message(true, "Nhập thông tin thành công!")
          _ -> Helper.response_json_message(false, "Có lỗi xảy ra", 406)
        end
      end
    json conn, res
  end

  def contribute_household_data(conn, params) do
    user_id = conn.assigns.user.user_id
    date = params["date"] |> Date.from_iso8601!
    data_entry = params["data_entry"] || []

    res =
      if (Enum.empty?(data_entry)) do Helper.response_json_message(false, "Không có thông tin để nhập", 406)
      else
        Repo.transaction(fn ->
          Enum.each(data_entry, fn d ->
            %{"factor_id" => factor_id, "quantity" => quantity} = d
            %HouseholdContribution{
              date: date,
              user_id: user_id,
              factor_id: factor_id,
              quantity: :erlang.float(quantity)
            } |> Repo.insert
          end)
        end)
        |> case do
          {:ok, _} -> Helper.response_json_message(true, "Nhập thông tin thành công!")
          _ -> Helper.response_json_message(false, "Có lỗi xảy ra", 406)
        end
      end
    json conn, res
  end


  def edit_factor_quantity(conn, params) do
    user_id = conn.assigns.user.user_id
    factor_id = params["factor_id"] || 0
    quantity = params["quantity"] || 0
    type = params["type"] || "scrap"
    date = params["date"] |> Date.from_iso8601!
    
    model = if (type == "scrap"), do: ScraperContribution, else: HouseholdContribution
    res = model
    |> where([m], m.user_id == ^user_id and m.factor_id == ^factor_id and m.date == ^date)
    |> select([m], m)
    |> Repo.one
    |> case do
      nil -> Helper.response_json_message(false, "Bạn chưa nhập thông tin ngày hôm nay", 407)
      entry ->
        maximum_time_can_edit = entry.inserted_at |> NaiveDateTime.add(86400)
        can_edit = NaiveDateTime.utc_now |> NaiveDateTime.before?(maximum_time_can_edit)

        if (can_edit) do
          data_changes = %{factor_id: factor_id, quantity: :erlang.float(quantity)}
          Ecto.Changeset.change(entry, data_changes)
          |> Repo.update
          |> case do
            {:ok, updated_entry} ->
              key_drop = if (type == "scrap"), do: :scrap_constant_factor, else: :household_constant_factor
              entry = Map.from_struct(updated_entry) |> Map.drop([:__meta__, :user, key_drop]) |> Enum.into(%{})
              Helper.response_json_with_data(true, "Cập nhật số liệu thành công!", entry)
            _ -> Helper.response_json_message(false, "Không thể update thông tin!", 407)
          end
        else
          Helper.response_json_message(false, "Không thể thay đổi thông tin sau 24h!", 408)
        end
    end

    json conn, res
  end

  def get_contribution_for_user(conn, params) do
    user_id_request = conn.assigns.user.user_id
    role_id_request = conn.assigns.user.role_id

    date = params["date"]

    res = cond do
      is_list(date) && length(date) == 2 ->
        [start_date, end_date] = date |> Enum.map(&Date.from_iso8601!/1)

        data = ScraperContribution
        |> where([sc], sc.date >= ^start_date and sc.date <= ^end_date and sc.user_id == ^user_id_request)
        |> order_by([sc], desc: sc.date)
        |> select([sc], %{user_id: sc.user_id, date: sc.date, factor_id: sc.factor_id, quantity: sc.quantity, inserted_at: sc.inserted_at})
        |> Repo.all
        Helper.response_json_with_data(true, "Lấy dữ liệu thành công!", data)

      is_binary(date) ->
        data = ScraperContribution
        |> where([sc], sc.date == ^date)
        |> order_by([sc], desc: sc.date)
        |> select([sc], %{user_id: sc.user_id, date: sc.date, factor_id: sc.factor_id, quantity: sc.quantity, inserted_at: sc.inserted_at})
        |> Repo.all

        Helper.response_json_with_data(true, "Lấy dữ liệu thành công!", data)

      true ->
        Helper.response_json_message(false, "Có lỗi xảy ra!", 405)
    end
    json conn, res
  end

  # def get_contribution_for_admin(user_id, date) do
  #   user_id_request = conn.assigns.user.user_id
  #   role_id_request = conn.assigns.user.role_id

  #   date = params["date"]
  #   user_id = params["user_id"]

  #   res = cond do
  #     is_list(date) && length(date) == 2 ->
  #       [start_date, end_date] = date |> Enum.map(&Date.from_iso8601!/1)

  #       data = ScraperContribution
  #       |> where([sc], sc.date >= ^start_date and sc.date <= ^end_date)
  #       |> order_by([sc], desc: sc.date)
  #       |> select([sc], %{user_id: sc.user_id, date: sc.date, factor_id: sc.factor_id, quantity: sc.quantity, inserted_at: sc.inserted_at})
  #       |> Repo.all
  #       Helper.response_json_with_data(true, "Lấy dữ liệu thành công!", data)

  #     is_binary(date) ->
  #       data = ScraperContribution
  #       |> where([sc], sc.date == ^date)
  #       |> order_by([sc], desc: sc.date)
  #       |> select([sc], %{user_id: sc.user_id, date: sc.date, factor_id: sc.factor_id, quantity: sc.quantity, inserted_at: sc.inserted_at})
  #       |> Repo.all

  #       Helper.response_json_with_data(true, "Lấy dữ liệu thành công!", data)

  #     true ->
  #       Helper.response_json_message(false, "Có lỗi xảy ra!", 405)
  #   end
  #   json conn, res
  # end
end
