defmodule HexDocsSearch.Repo.Migrations.AddDocsConfig do
  use Ecto.Migration

  def change do
    alter table(:packages) do
      add :docs_config_json, {:array, :map}
    end
  end
end
