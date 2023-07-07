defmodule HexDocsSearchWeb.PackageLive.Index do
  use HexDocsSearchWeb, :live_view

  alias HexDocsSearch.Hex
  alias HexDocsSearch.Hex.Package

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :packages, Hex.list_packages(1000))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Package")
    |> assign(:package, Hex.get_package!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Package")
    |> assign(:package, %Package{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Packages")
    |> assign(:package, nil)
  end

  @impl true
  def handle_info({HexDocsSearchWeb.PackageLive.FormComponent, {:saved, package}}, socket) do
    {:noreply, stream_insert(socket, :packages, package)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    package = Hex.get_package!(id)
    {:ok, _} = Hex.delete_package(package)

    {:noreply, stream_delete(socket, :packages, package)}
  end
end
