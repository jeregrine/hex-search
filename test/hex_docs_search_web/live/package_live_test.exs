defmodule HexDocsSearchWeb.PackageLiveTest do
  use HexDocsSearchWeb.ConnCase

  import Phoenix.LiveViewTest
  import HexDocsSearch.HexFixtures

  @create_attrs %{meta: %{}, name: "some name", docs_html_url: "some docs_html_url", downloads_all: 42, downloads_day: 42, downloads_recent: 42, downloads_week: 42, latest_docs_url: "some latest_docs_url", html_url: "some html_url", latest_stable_version: "some latest_stable_version", search_items_json: %{}, sidebar_items_json: %{}, last_pulled: "2023-07-06T17:59:00Z"}
  @update_attrs %{meta: %{}, name: "some updated name", docs_html_url: "some updated docs_html_url", downloads_all: 43, downloads_day: 43, downloads_recent: 43, downloads_week: 43, latest_docs_url: "some updated latest_docs_url", html_url: "some updated html_url", latest_stable_version: "some updated latest_stable_version", search_items_json: %{}, sidebar_items_json: %{}, last_pulled: "2023-07-07T17:59:00Z"}
  @invalid_attrs %{meta: nil, name: nil, docs_html_url: nil, downloads_all: nil, downloads_day: nil, downloads_recent: nil, downloads_week: nil, latest_docs_url: nil, html_url: nil, latest_stable_version: nil, search_items_json: nil, sidebar_items_json: nil, last_pulled: nil}

  defp create_package(_) do
    package = package_fixture()
    %{package: package}
  end

  describe "Index" do
    setup [:create_package]

    test "lists all packages", %{conn: conn, package: package} do
      {:ok, _index_live, html} = live(conn, ~p"/packages")

      assert html =~ "Listing Packages"
      assert html =~ package.name
    end

    test "saves new package", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/packages")

      assert index_live |> element("a", "New Package") |> render_click() =~
               "New Package"

      assert_patch(index_live, ~p"/packages/new")

      assert index_live
             |> form("#package-form", package: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#package-form", package: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/packages")

      html = render(index_live)
      assert html =~ "Package created successfully"
      assert html =~ "some name"
    end

    test "updates package in listing", %{conn: conn, package: package} do
      {:ok, index_live, _html} = live(conn, ~p"/packages")

      assert index_live |> element("#packages-#{package.id} a", "Edit") |> render_click() =~
               "Edit Package"

      assert_patch(index_live, ~p"/packages/#{package}/edit")

      assert index_live
             |> form("#package-form", package: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#package-form", package: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/packages")

      html = render(index_live)
      assert html =~ "Package updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes package in listing", %{conn: conn, package: package} do
      {:ok, index_live, _html} = live(conn, ~p"/packages")

      assert index_live |> element("#packages-#{package.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#packages-#{package.id}")
    end
  end

  describe "Show" do
    setup [:create_package]

    test "displays package", %{conn: conn, package: package} do
      {:ok, _show_live, html} = live(conn, ~p"/packages/#{package}")

      assert html =~ "Show Package"
      assert html =~ package.name
    end

    test "updates package within modal", %{conn: conn, package: package} do
      {:ok, show_live, _html} = live(conn, ~p"/packages/#{package}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Package"

      assert_patch(show_live, ~p"/packages/#{package}/show/edit")

      assert show_live
             |> form("#package-form", package: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#package-form", package: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/packages/#{package}")

      html = render(show_live)
      assert html =~ "Package updated successfully"
      assert html =~ "some updated name"
    end
  end
end
