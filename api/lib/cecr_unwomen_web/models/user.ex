defmodule CecrUnwomenWeb.Models.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias CecrUnwomenWeb.Models.Role

  @primary_key {:id, Ecto.UUID, autogenerate: false}
  schema "user" do
    field :first_name, :string
    field :last_name, :string
    field :avatar_url, :string
    field :phone_number, :string
    field :email, :string
    field :password_hash, :string
    field :gender, :integer, default: 2
    field :date_of_birth, :date
    field :location, :string
    field :refresh_token, :string
    field :verified, :boolean

    belongs_to :role, Role, foreign_key: :role_id, type: :integer
    timestamps()
  end

  @required_fields [:id, :first_name, :last_name, :phone_number, :password_hash, :role_id, :refresh_token]
  @optional_fields [:avatar_url, :email, :gender, :date_of_birth, :location, :verified]

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
