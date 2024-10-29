defmodule CecrUnwomen.Repo.Migrations.AddTimestampsForTables do
  use Ecto.Migration

  def change do
    alter table(:household_constant_factor) do
      timestamps()
    end

    alter table(:household_contribution) do
      timestamps()
    end

    alter table(:scrap_constant_factor) do
      timestamps()
    end

    alter table(:scraper_contribution) do
      timestamps()
    end

    alter table(:role) do
      timestamps()
    end
  end
end
