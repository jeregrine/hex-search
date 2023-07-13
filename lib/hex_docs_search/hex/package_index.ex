defmodule HexDocsSearch.Hex.PackageIndex do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true, source: :rowid}
  schema "packages_index" do
    field :doc, :string
    field :title, :string
    field :ref, :string
    field :type, Ecto.Enum, values: [:function, :module, :type, :protocol, :behaviour, :callback, :opaque, :exception, :macrocallback, :macro, :extras, :task]
    field :rank, :float 
    belongs_to :package, HexDocsSearch.Hex.Package, foreign_key: :package_id
  end

  @doc false
  def changeset(package, attrs) do
    package
    |> cast(attrs, [:doc, :title, :ref, :type])
    |> validate_required([:doc, :title, :ref, :type])
  end
end
