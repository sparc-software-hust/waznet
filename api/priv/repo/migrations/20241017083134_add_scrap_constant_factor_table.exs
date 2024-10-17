defmodule CecrUnwomen.Repo.Migrations.AddScrapConstantFactorTable do
  use Ecto.Migration

  def change do
		create table(:scrap_constant_factor) do
			add :name, 		:string
			add :value, 	:integer, null: false
			add :unit,		:string, null: false
		end
  end
end
