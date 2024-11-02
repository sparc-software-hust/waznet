defmodule CecrUnwomen.Repo.Migrations.ChangeIntToFloatQuantityContribution do
  use Ecto.Migration

  def change do
    alter table(:scraper_contribution) do
      modify :quantity, :float, default: 0.0
    end

    alter table(:household_contribution) do
      modify :quantity, :float, default: 0.0
    end
  end
end
