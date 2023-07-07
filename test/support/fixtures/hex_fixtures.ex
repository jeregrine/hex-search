defmodule HexDocsSearch.HexFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HexDocsSearch.Hex` context.
  """

  @doc """
  Generate a package.
  """
  def package_fixture(attrs \\ %{}) do
    {:ok, package} =
      attrs
      |> Enum.into(%{
        meta: %{},
        name: "some name",
        docs_html_url: "some docs_html_url",
        downloads_all: 42,
        downloads_day: 42,
        downloads_recent: 42,
        downloads_week: 42,
        latest_docs_url: "some latest_docs_url",
        html_url: "some html_url",
        latest_stable_version: "some latest_stable_version",
        search_items_json: %{},
        sidebar_items_json: %{},
        last_pulled: ~U[2023-07-06 17:59:00Z]
      })
      |> HexDocsSearch.Hex.create_package()

    package
  end
end
