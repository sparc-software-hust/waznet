defmodule CecrUnwomen.Repo.Migrations.AddFirebaseTokenTable do
  use Ecto.Migration

  def change do
    create table(:firebase_token) do
      add :token,      :string
      add :apns_token, :string
      add :platform,   :string
      add :user_id,    references(:user, on_delete: :nilify_all, column: :id, type: :uuid)
      timestamps()
    end
  end
end
