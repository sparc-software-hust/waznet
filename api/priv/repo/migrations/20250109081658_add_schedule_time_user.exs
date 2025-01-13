defmodule CecrUnwomen.Repo.Migrations.AddScheduleTimeUser do
  use Ecto.Migration

  def change do
    alter table(:user) do
      add :time_reminded, :naive_datetime
    end
  end
end
