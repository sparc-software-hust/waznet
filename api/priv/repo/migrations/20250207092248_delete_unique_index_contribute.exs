defmodule CecrUnwomen.Repo.Migrations.DeleteUniqueIndexContribute do
  use Ecto.Migration

  def change do
    drop index(:household_contribution, [:date, :user_id, :factor_id], name: :date_user_id_factor_id_household_contribution_unique_index)
    drop index(:scraper_contribution, [:date, :user_id, :factor_id], name: :date_user_id_factor_id_scraper_contribution_unique_index)
    
    create index(:household_contribution, [:date, :user_id, :factor_id], name: :date_user_id_factor_id_household_contribution_index)
    create index(:scraper_contribution, [:date, :user_id, :factor_id], name: :date_user_id_factor_id_scraper_contribution_index)
  end
end
