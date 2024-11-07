defmodule CecrUnwomen.Repo.Migrations.AddFieldKgCo2eRecycleHousehold do
  use Ecto.Migration

  def change do
		alter table(:overall_household_contribution) do
			remove :kg_co2e_reduced
			add :kg_co2e_plastic_reduced, :float, null: false
			add :kg_co2e_recycle_reduced, :float, null: false
		end
  end
end
