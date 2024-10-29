defmodule CecrUnwomen.Repo.Migrations.AddExcelExportTable do
  use Ecto.Migration

  def change do
    create table(:excel_export) do
      add :name, :string, null: false
      add :type, :string, null: false
      add :download_path, :string
      timestamps()
    end

    create unique_index(:excel_export, [:name, :type], name: :name_type_excel_export_unique_index)
  end
end
