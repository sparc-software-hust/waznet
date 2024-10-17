defmodule CecrUnwomen.Repo.Migrations.AddUserTable do
  use Ecto.Migration

  def change do
		create table(:user, primary_key: false) do
			add :id,            :uuid, primary_key: true
      add :first_name,     :string
      add :last_name,     :string
      add :avatar_url,    :string
			add :phone_number,  :string, null: false
			add :email,					:string
			add :role_id,       references(:role, on_delete: :nilify_all, column: :id, type: :integer), null: false
			add :gender,				:integer, default: 2
			add :date_of_birth,	:date
			add :access_token,	:string
			timestamps()
		end
  end
end
