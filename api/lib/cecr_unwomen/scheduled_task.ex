defmodule CecrUnWomen.ScheduledTask do
  alias CecrUnwomen.{Utils.Helper, Repo}
  alias CecrUnwomenWeb.Models.{
    User,
  }
  import Ecto.Query
  
  def test() do
    user_to_remind = from(
      u in User,
      where: not is_nil(u.time_reminded)
    ) 
    |> Repo.all
    |> IO.inspect()
  end 
end
