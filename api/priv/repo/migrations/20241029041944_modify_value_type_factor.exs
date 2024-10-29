defmodule CecrUnwomen.Repo.Migrations.ModifyValueTypeFactor do
  use Ecto.Migration

  def change do
    alter table(:household_constant_factor) do
      modify :value, :float
    end
    alter table(:scrap_constant_factor) do
      modify :value, :float
    end
  end
end
