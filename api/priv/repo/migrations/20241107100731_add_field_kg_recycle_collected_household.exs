defmodule CecrUnwomen.Repo.Migrations.AddFieldKgRecycleCollectedHousehold do
  use Ecto.Migration

  def change do
		alter table(:overall_household_contribution) do
			add :kg_recycle_collected, :float, null: false
		end
  end
end
