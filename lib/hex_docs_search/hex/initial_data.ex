defmodule HexDocsSearch.Hex.InitialData do
  alias HexDocsSearch.Hex

  def initialize!() do
    Path.expand("~/hex_docs.data")
    |> File.read!()
    |> :erlang.binary_to_term()
    |> Enum.map(fn d ->
      d = Map.take(d, ~w(
        docs_html_url
        downloads
        html_url
        latest_release
        latest_stable_version
        meta
        name
        search_items_json
        sidebar_items_json
        updated_at
      ))
      |> Map.put("downloads_all", get_in(d, ["downloads", "all"]) )
      |> Map.put("downloads_day", get_in(d, ["downloads", "day"]) )
      |> Map.put("downloads_recent", get_in(d, ["downloads", "recent"]))
      |> Map.put("downloads_week", get_in(d, ["downloads", "week"]))
      |> Map.delete("downloads")
      |> Map.put("latest_docs_url", get_in(d, ["latest_release", "url"]))
      |> Map.delete("latest_release")
      |> Map.put_new("last_pulled", DateTime.utc_now())

      sidebars = Map.get(d, "sidebar_items_json")
      sidebars = 
        cond do
          is_list(sidebars) -> %{weird: sidebars}
          is_binary(sidebars) -> %{unparsed: sidebars}
          true -> sidebars
        end

      d = Map.put(d, "sidebar_items_json", sidebars)

      search = Map.get(d, "search_items_json")
      search = 
        cond do
          is_list(search) -> [%{weird: search}]
          is_binary(search) -> [%{unparsed: search}]
          true -> search
        end

      Map.put(d, "search_items_json", search)
    end)
    |> Enum.map(fn pkg -> 
      case Hex.get_package(pkg["name"]) do
        nil -> 
          {pkg, Hex.create_package(pkg)}
        pkg ->
          {:ok, {:ok, pkg}}
      end
    end)
    |> Enum.map(fn 
      {_, {:ok, _}} -> true 
      blah -> IO.inspect(blah) 
    end)
  end
end
