defmodule CecrUnwomenWeb.Models.OverallHouseholdContribution do
  use Ecto.Schema
  import Ecto.Changeset
  alias CecrUnwomenWeb.Models. { User }

  schema "overall_household_contribution" do
    field :date, :date
    field :kg_co2e_plastic_reduced, :float
    field :kg_co2e_recycle_reduced, :float
    field :kg_recycle_collected, :float
    belongs_to :user, User, foreign_key: :user_id, type: Ecto.UUID
    timestamps()
  end

  @required_fields [:user_id, :date, :kg_co2e_plastic_reduced, :kg_co2e_recycle_reduced]

  def changeset(contribution, params \\ %{}) do
    contribution
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
