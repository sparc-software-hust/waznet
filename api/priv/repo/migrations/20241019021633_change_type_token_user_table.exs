defmodule CecrUnwomen.Repo.Migrations.ChangeTypeTokenUserTable do
  use Ecto.Migration

  def change do
    alter table(:user) do
      remove :access_token
      add :refresh_token, :string
    end
  end
end
