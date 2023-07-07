defmodule HexDocsSearch.Hex.Package do
  use Ecto.Schema
  import Ecto.Changeset

  schema "packages" do
    field :meta, :map
    field :name, :string
    field :docs_html_url, :string
    field :downloads_all, :integer, default: 0
    field :downloads_day, :integer, default: 0
    field :downloads_recent, :integer, default: 0
    field :downloads_week, :integer, default: 0
    field :latest_docs_url, :string
    field :html_url, :string
    field :latest_stable_version, :string
    field :last_pulled, :utc_datetime

    field :search_items_json, {:array, :map}
    field :sidebar_items_json, :map

    timestamps()
  end

  @doc false
  def changeset(package, attrs) do
    package
    |> cast(attrs, [:name, :docs_html_url, :downloads_all, :downloads_day, :downloads_recent, :downloads_week, :latest_docs_url, :html_url, :latest_stable_version, :meta, :search_items_json, :sidebar_items_json, :last_pulled])
    |> validate_required([:name, :docs_html_url, :html_url, :meta])
  end
end
