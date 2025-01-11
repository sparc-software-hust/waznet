defmodule CecrUnwomen.ScheduledTask do
  alias CecrUnwomen.{Utils.Helper, Repo, Consumer}
  alias CecrUnwomen.Workers.{ScheduleWorker, FcmWorker}
  alias CecrUnwomenWeb.Models.{
    User,
    FirebaseToken
  }
  import Ecto.Query
  
  #timezone VietNam
  def send_noti_remind_vi() do
    user_to_remind = from(
      u in User,
      join: ft in FirebaseToken,
      on: u.id == ft.user_id,
      where: not is_nil(u.time_reminded),
      select: %{
        "user_id" => u.id,
        "token" => ft.token,
        "time_reminded" => u.time_reminded,
      }
    ) 
    |> Repo.all
    # fold cac token thuoc cung 1 user lai ve 1 map 
    |> Enum.reduce(%{}, fn item, acc ->
      user_id = item["user_id"]
      {_, {hour, minute, _}}= item["time_reminded"] |> NaiveDateTime.to_erl()
      time_reminded = %{
        "hour" => hour,
        "minute" => minute
      }
      token = item["token"]

      Map.update(acc, user_id, %{
        "user_id" => user_id,
        "time_reminded" => time_reminded,
        "tokens" => [token]
      }, fn existing ->
        Map.update(existing, "tokens", [token], fn tokens -> tokens ++ [token] end)
      end)
    end)
    |> Map.values()

    # channel  =  Application.get_env(:cecr_unwomen, :r_channel)
    
    # AMQP.Basic.publish channel, "", "wait_min_30", "djhasbdjbsb", persistent: true
    
    ScheduleWorker.schedule_to_send_noti_vi(user_to_remind) 
  end
end
