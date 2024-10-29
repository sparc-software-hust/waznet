defmodule CecrUnwomen.Repo.Migrations.AddScraperContributionTable do
  use Ecto.Migration

  def change do
    create table(:scraper_contribution) do
      add :user_id, references(:user, column: :id, type: :uuid), null: false
      add :date, :date, null: false
      add :factor_id, references(:scrap_constant_factor, column: :id, type: :integer), null: false
      add :quantity, :integer
    end
    create unique_index(:scraper_contribution, [:date, :user_id, :factor_id], name: :date_user_id_factor_id_scraper_contribution_unique_index)
  end
end
