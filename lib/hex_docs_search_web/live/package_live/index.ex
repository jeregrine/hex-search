defmodule HexDocsSearchWeb.PackageLive.Index do
  use HexDocsSearchWeb, :live_view

  alias HexDocsSearch.Hex
  alias HexDocsSearch.Hex.{Package, PackageIndex}

  @impl true
  def mount(_params, _session, socket) do

    {:ok, 
      socket
      |> assign(:page_title, "HexDocs Search")
      |> assign(:search, "")
      |> stream(:documents, [])
    }
  end

  @impl true
  def handle_params(%{"search" => search}, _url, socket) do
    {:noreply, search(socket, search)}
  end


  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, 
      socket
      |> stream(:documents, Hex.list_packages(100), reset: true)
      |> assign(:search, "")
    }
  end

  @impl true
  def handle_event("search", %{"value" => ""}, socket) do
    {:noreply, push_patch(socket, to: ~p"/")}
  end

  @impl true
  def handle_event("search", %{"value" => search}, socket) do
    {:noreply, push_patch(socket, to: ~p"/?#{%{search: search}}", replace: true)}
  end

  def search(socket, search) do
    socket
    |> assign(:form, to_form(%{"search" => search}))
    |> stream(:documents, Hex.search_packages(search), reset: true)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="font-mono">
      <div class="text-4xl font-bold">
        Search HexDocs
      </div>

      <.search_input value={@search}/>
      <.search_results docs={@streams.documents} />
    </div>
    """
  end

  defp search_input(assigns) do
    ~H"""
      <div class="relative ">
        <!-- Heroicon name: mini/magnifying-glass -->
        <svg class="pointer-events-none absolute top-3.5 left-4 h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
          <path fill-rule="evenodd" d="M9 3.5a5.5 5.5 0 100 11 5.5 5.5 0 000-11zM2 9a7 7 0 1112.452 4.391l3.328 3.329a.75.75 0 11-1.06 1.06l-3.329-3.328A7 7 0 012 9z" clip-rule="evenodd" />
        </svg>
        <input value={@value} type="text" 
              class="h-12 w-full border-none focus:ring-0 pl-11 pr-4 text-gray-800 placeholder-gray-400 sm:text-sm" 
              phx-keyup="search" 
              phx-debounce="150" 
              placeholder="Search everything..." 
              role="combobox" 
              aria-expanded="false" 
              aria-controls="options" 
        />
      </div>
    """
  end

  defp search_results(assigns) do
    ~H"""
      <ul class="-mb-2 py-2 text-sm text-gray-800 flex space-y-2 flex-col" id="options" role="listbox">
        <li :if={@docs == []} id="option-none" role="option" tabindex="-1" class="cursor-default select-none px-4 py-2 text-xl">
          No Results
        </li>

        <.link navigate={ get_url(doc) } id={"doc-#{doc.id}"} :for={{doc_id, doc} <- @docs}>
          <.result_item doc={doc} doc_id={doc_id} />
        </.link>
      </ul>
    """
  end

  attr :doc, :map, required: true
  attr :doc_id, :string, required: true
  defp result_item(assigns) do
    ~H"""
      <li id={@doc_id} class="cursor-default select-none px-4 py-2 text-xl bg-zinc-100 hover:bg-zinc-800 hover:text-white hover:cursor-pointer flex flex-row space-x-5 items-center" role="option" tabindex="-1">
        <div class="flex-none w-16">
          <.doc_icon doc={@doc} />
        </div>

        <div class="grow overflow-x-scroll md:overflow-auto">
          <%= get_title(@doc) %>
        </div>
      </li>
    """
  end

  def doc_icon(assigns) do
    ~H"""
      <p class="block border border-gray-400 px-2 text-[0.5rem] leading-tight first-letter:text-xl first-letter:font-bold first-letter:text-slate-900">
        <%= icon_name(@doc) %>
      </p>
    """
  end

  def icon_name(%Package{}), do: "Package"
  def icon_name(%PackageIndex{type: type}), do: type |> Atom.to_string() |> String.capitalize() 

  defp get_url(%PackageIndex{} = idx) do
    idx.package.docs_html_url <> idx.ref
  end
  defp get_url(%Package{} = pkg) do
    pkg.docs_html_url
  end

  defp get_title(%PackageIndex{title: title}), do: title
  defp get_title(%Package{name: name}), do: name
end
