defmodule HexDocsSearchWeb.PackageLive.Index do
  use HexDocsSearchWeb, :live_view

  alias HexDocsSearch.Hex

  @impl true
  def mount(_params, _session, socket) do
    {:ok, 
      socket
      |> assign(:page_title, "HexDocs Search")
      |> assign(:form, to_form(%{"search" => ""}))
      |> stream(:named_packages,[])
    }
  end

  @impl true
  def handle_params(%{"search" => search}, _url, socket) do
    {:noreply, search(socket, search)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    {:noreply, search(socket, search)}
  end

  def search(socket, search) do
    socket
    |> assign(:form, to_form(%{"search" => search}))
    |> stream(:named_packages, Hex.search_packages(search), reset: true)
  end
end
