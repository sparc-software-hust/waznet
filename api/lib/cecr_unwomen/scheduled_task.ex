defmodule CecrUnWomen.ScheduledTask do
  alias CecrUnwomen.{Utils.Helper, Repo, Consumer}
  alias CecrUnwomenWeb.Models.{
    User,
  }
  import Ecto.Query
  
  def test() do
    # now = DateTime.utc_now()
    #  |> DateTime.shift_zone(utc_datetime, "America/New_York")
    user_to_remind = from(
      u in User,
      where: not is_nil(u.time_reminded)
    ) 
    |> Repo.all
    |> IO.inspect()
  end 
  
  # channel  =  Application.get_env(:cecr_unwomen, :r_channel)
  # AMQP.Basic.publish channel, "", "wait_min_1", "Hello world", persistent: true
end
