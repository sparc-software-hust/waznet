defmodule CecrUnwomen.Repo.Migrations.AddFieldIsRemovedUserTable do
  use Ecto.Migration

  def change do
    alter table(:user) do
      add :is_removed, :boolean, default: false
    end
  end
end
