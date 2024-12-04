defmodule CecrUnwomen.Repo.Migrations.ChangeLocationUser do
  use Ecto.Migration

  def change do
    alter table(:user) do
      modify :location, :text
    end
  end
end
