defmodule HexDocsSearch.Repo.Migrations.AddFTSIndex do
  use Ecto.Migration

  def up do
    execute """
      CREATE VIRTUAL TABLE packages_index USING fts5(
        doc,
        title,
        type,
        ref UNINDEXED,
        package_id UNINDEXED,
      tokenize="porter")
    """
  end

  def down do
    drop table("packages_index")
  end
end
