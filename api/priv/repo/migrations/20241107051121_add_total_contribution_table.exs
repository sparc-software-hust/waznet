defmodule CecrUnwomen.Repo.Migrations.AddTotalContributionTable do
  use Ecto.Migration

  def change do
    create table(:overall_scraper_contribution) do
      add :user_id, references(:user, column: :id, type: :uuid), null: false
      add :date, :date, null: false
      add :kg_co2e_reduced, :float, null: false
      add :expense_reduced, :float
      timestamps()
    end

    create table(:overall_household_contribution) do
      add :user_id, references(:user, column: :id, type: :uuid), null: false
      add :date, :date, null: false
      add :kg_co2e_reduced, :float, null: false
      timestamps()
    end

    create unique_index(:overall_scraper_contribution, [:date, :user_id], name: :date_user_id_overall_scraper_contribution_unique_index)
    create unique_index(:overall_household_contribution, [:date, :user_id], name: :date_user_id_overall_household_contribution_unique_index)
  end
end
