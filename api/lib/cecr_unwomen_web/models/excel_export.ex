defmodule CecrUnwomenWeb.Models.ExcelExport do
  use Ecto.Schema
  import Ecto.Changeset

  schema "excel_export" do
    field :name, :string
    field :type, :string
    field :download_path, :string

    timestamps()
  end

  @required_fields [:name, :type]

  def changeset(excel_export, params \\ %{}) do
    excel_export
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end

# 4 types: date, range, month, year
# - each type has each name:
#   + date: name is date => 24_10_2024
#   + range: name is range => 24_10_2024_27_10_2024
#   + date: name is month => 10_2024
#   + date: name is year => 2024
