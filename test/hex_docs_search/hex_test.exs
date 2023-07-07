defmodule HexDocsSearch.HexTest do
  use HexDocsSearch.DataCase

  alias HexDocsSearch.Hex

  describe "packages" do
    alias HexDocsSearch.Hex.Package

    import HexDocsSearch.HexFixtures

    @invalid_attrs %{meta: nil, name: nil, docs_html_url: nil, downloads_all: nil, downloads_day: nil, downloads_recent: nil, downloads_week: nil, latest_docs_url: nil, html_url: nil, latest_stable_version: nil, search_items_json: nil, sidebar_items_json: nil, last_pulled: nil}

    test "list_packages/0 returns all packages" do
      package = package_fixture()
      assert Hex.list_packages() == [package]
    end

    test "get_package!/1 returns the package with given id" do
      package = package_fixture()
      assert Hex.get_package!(package.id) == package
    end

    test "create_package/1 with valid data creates a package" do
      valid_attrs = %{meta: %{}, name: "some name", docs_html_url: "some docs_html_url", downloads_all: 42, downloads_day: 42, downloads_recent: 42, downloads_week: 42, latest_docs_url: "some latest_docs_url", html_url: "some html_url", latest_stable_version: "some latest_stable_version", search_items_json: %{}, sidebar_items_json: %{}, last_pulled: ~U[2023-07-06 17:59:00Z]}

      assert {:ok, %Package{} = package} = Hex.create_package(valid_attrs)
      assert package.meta == %{}
      assert package.name == "some name"
      assert package.docs_html_url == "some docs_html_url"
      assert package.downloads_all == 42
      assert package.downloads_day == 42
      assert package.downloads_recent == 42
      assert package.downloads_week == 42
      assert package.latest_docs_url == "some latest_docs_url"
      assert package.html_url == "some html_url"
      assert package.latest_stable_version == "some latest_stable_version"
      assert package.search_items_json == %{}
      assert package.sidebar_items_json == %{}
      assert package.last_pulled == ~U[2023-07-06 17:59:00Z]
    end

    test "create_package/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hex.create_package(@invalid_attrs)
    end

    test "update_package/2 with valid data updates the package" do
      package = package_fixture()
      update_attrs = %{meta: %{}, name: "some updated name", docs_html_url: "some updated docs_html_url", downloads_all: 43, downloads_day: 43, downloads_recent: 43, downloads_week: 43, latest_docs_url: "some updated latest_docs_url", html_url: "some updated html_url", latest_stable_version: "some updated latest_stable_version", search_items_json: %{}, sidebar_items_json: %{}, last_pulled: ~U[2023-07-07 17:59:00Z]}

      assert {:ok, %Package{} = package} = Hex.update_package(package, update_attrs)
      assert package.meta == %{}
      assert package.name == "some updated name"
      assert package.docs_html_url == "some updated docs_html_url"
      assert package.downloads_all == 43
      assert package.downloads_day == 43
      assert package.downloads_recent == 43
      assert package.downloads_week == 43
      assert package.latest_docs_url == "some updated latest_docs_url"
      assert package.html_url == "some updated html_url"
      assert package.latest_stable_version == "some updated latest_stable_version"
      assert package.search_items_json == %{}
      assert package.sidebar_items_json == %{}
      assert package.last_pulled == ~U[2023-07-07 17:59:00Z]
    end

    test "update_package/2 with invalid data returns error changeset" do
      package = package_fixture()
      assert {:error, %Ecto.Changeset{}} = Hex.update_package(package, @invalid_attrs)
      assert package == Hex.get_package!(package.id)
    end

    test "delete_package/1 deletes the package" do
      package = package_fixture()
      assert {:ok, %Package{}} = Hex.delete_package(package)
      assert_raise Ecto.NoResultsError, fn -> Hex.get_package!(package.id) end
    end

    test "change_package/1 returns a package changeset" do
      package = package_fixture()
      assert %Ecto.Changeset{} = Hex.change_package(package)
    end
  end
end
