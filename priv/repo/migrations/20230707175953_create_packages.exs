defmodule HexDocsSearch.Repo.Migrations.CreatePackages do
  use Ecto.Migration

  def change do
    create table(:packages) do
      add :name, :string
      add :docs_html_url, :string
      add :downloads_all, :integer
      add :downloads_day, :integer
      add :downloads_recent, :integer
      add :downloads_week, :integer
      add :latest_docs_url, :string
      add :html_url, :string
      add :latest_stable_version, :string
      add :meta, :map
      add :last_pulled, :utc_datetime

      add :sidebar_items_json, :map
      add :search_items_json, {:array, :map}

      timestamps()
    end
  end
end
