defmodule CecrUnwomen.Repo.Migrations.AddHouseholdContributionTable do
  use Ecto.Migration

  def change do
		create table(:household_daily_contribution) do
			add :date,    :date, null: false
			# add :
		end
  end
end
