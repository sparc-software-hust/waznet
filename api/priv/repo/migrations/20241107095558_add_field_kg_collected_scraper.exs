defmodule CecrUnwomen.Repo.Migrations.AddFieldKgCollectedScraper do
  use Ecto.Migration

  def change do
		alter table(:overall_scraper_contribution) do
			add :kg_collected, :float, null: false
		end
  end
end
