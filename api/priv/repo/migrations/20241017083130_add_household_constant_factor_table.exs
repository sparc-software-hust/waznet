defmodule CecrUnwomen.Repo.Migrations.AddHouseholdConstantFactorTable do
  use Ecto.Migration

  def change do
    create table(:household_constant_factor) do
      add :name, :string
      add :value, :integer, null: false
      add :unit, :string, null: false
    end
  end
end
