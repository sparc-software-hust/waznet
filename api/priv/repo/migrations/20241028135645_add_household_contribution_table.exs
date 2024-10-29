defmodule CecrUnwomen.Repo.Migrations.AddHouseholdContributionTable do
  use Ecto.Migration

  def change do
    create table(:household_contribution) do
      add :user_id, references(:user, column: :id, type: :uuid), null: false
      add :date, :date, null: false
      add :factor_id, references(:household_constant_factor, column: :id, type: :integer), null: false
      add :quantity, :integer, default: 0
    end
    create unique_index(:household_contribution, [:date, :user_id, :factor_id], name: :date_user_id_factor_id_household_contribution_unique_index)
  end
end
