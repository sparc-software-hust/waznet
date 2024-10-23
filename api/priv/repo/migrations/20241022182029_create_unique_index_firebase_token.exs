defmodule CecrUnwomen.Repo.Migrations.CreateUniqueIndexFirebaseToken do
  use Ecto.Migration

  def change do
    create unique_index(:firebase_token, [:token, :user_id], name: :token_user_id_firebase_token_unique_index)
    create unique_index(:firebase_token, [:apns_token, :user_id], name: :apns_token_user_id_firebase_token_unique_index)
  end
end
