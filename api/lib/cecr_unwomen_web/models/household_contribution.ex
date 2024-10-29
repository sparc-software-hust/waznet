defmodule CecrUnwomenWeb.Models.HouseholdContribution do
  use Ecto.Schema
  import Ecto.Changeset
  alias CecrUnwomenWeb.Models. { User, HouseholdConstantFactor }

  schema "household_contribution" do
    field :date, :date
    field :quantity, :integer, default: 0

    belongs_to :user, User, foreign_key: :user_id, type: Ecto.UUID
    belongs_to :household_constant_factor, HouseholdConstantFactor, foreign_key: :factor_id, type: :integer
    timestamps()
  end

  @required_fields [:user_id, :factor_id, :date]

  def changeset(household_contribution, params \\ %{}) do
    household_contribution
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
