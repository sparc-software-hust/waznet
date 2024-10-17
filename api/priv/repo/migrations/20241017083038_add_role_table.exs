defmodule CecrUnwomen.Repo.Migrations.AddRoleTable do
  use Ecto.Migration

  def change do
		create table(:role, primary_key: false) do
			add :id,     			:integer
			add :name,   			:string
			add :description,	:string
		end
  end
end
