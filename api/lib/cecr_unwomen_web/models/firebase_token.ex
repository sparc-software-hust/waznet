defmodule CecrUnwomenWeb.Models.FirebaseToken do
  use Ecto.Schema
  import Ecto.Changeset
  alias CecrUnwomenWeb.Models.User

  schema "firebase_token" do
    field :token,      :string
    field :apns_token, :string
    field :platform,   :string

    belongs_to :user, User, foreign_key: :user_id, type: Ecto.UUID
    timestamps()
  end

  @optional_fields [:token, :apns_token, :platform, :user_id]

  def changeset(token, params \\ %{}) do
    token
    |> cast(params, @optional_fields)
    # |> validate_required(@required_fields)
  end
end
