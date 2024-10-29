defmodule CecrUnwomenWeb.Models.ScraperContribution do
  use Ecto.Schema
  import Ecto.Changeset
  alias CecrUnwomenWeb.Models. { User, ScrapConstantFactor }

  schema "scraper_contribution" do
    field :date, :date
    field :quantity, :integer, default: 0

    belongs_to :user, User, foreign_key: :user_id, type: Ecto.UUID
    belongs_to :scrap_constant_factor, ScrapConstantFactor, foreign_key: :factor_id, type: :integer
    timestamps()
  end

  @required_fields [:user_id, :factor_id, :date]

  def changeset(contribution, params \\ %{}) do
    contribution
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
