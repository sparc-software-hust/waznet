defmodule CecrUnwomen.Repo.Migrations.ChangeTypeRefreshToken do
  use Ecto.Migration

  def change do
    alter table(:user) do
      modify :refresh_token, :text
    end
  end
end
