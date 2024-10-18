defmodule CecrUnwomenWeb.Models.Role do
  use Ecto.Schema
	import Ecto.Changeset

  @primary_key {:id, :integer, autogenerate: false}
  schema "role" do
    field :name, :string
    field :description, :string
    timestamps()
  end

  def changeset(role, params \\ %{}) do
    role
    |> cast(params, [:name, :description])
    |> validate_required([:name, :description])
  end
end
