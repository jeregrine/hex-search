defmodule HexDocsSearch.Hex.Hydrator do
  alias HexDocsSearch.Hex
  alias HexDocsSearch.Hex.{Package, API, SimpleJSON}
  alias HexDocsSearch.Repo
  import Ecto.Query, only: [from: 2]

  def find_outdated() do
    last_pulled = from(p in Package, order_by: [desc: p.last_pulled], limit: 1, select: p.last_pulled) |> Repo.one!()
    
    Enum.reduce_while(1..500, [], fn page, acc ->
      data = API.list!(%{page: page, sort: "updated_at"})
      |> Enum.filter(fn pkg ->
        IO.inspect(pkg["updated_at"])
        {:ok, dt,_} = DateTime.from_iso8601(pkg["updated_at"]) 
        DateTime.compare(dt, last_pulled) == :gt
      end)

      current = Enum.count(data)
      if current < 100 do
        {:halt, [data | acc]}
      else
        {:cont, [data | acc]}
      end  
    end)
    |> List.flatten() 
    |> Kernel.++(Hex.InitialData.special_packages())
    |> Enum.map(fn pkg -> 
      case Hex.get_package(pkg["name"]) do
        nil ->
          {:ok, package} = Hex.create_package(pkg)
          package(package, pkg)
        package ->
          package(package, pkg)
      end
    end)
  end

  def package(%Package{} = package) do
    pkg = API.get!(package.name)
    package(package, pkg)
  end

  def package(%Package{} = package, pkg) do
    url = pkg["docs_html_url"]


    search_url = url <> "search.html"
    html = grab_html(search_url)

    docs_config_json = Task.async(fn ->
      html
      |> grab_json(["docs_config"], url)
      |> SimpleJSON.try_decode()
    end)

    search_items_json = Task.async(fn ->
      html
      |> grab_json(["search_items", "search_data"], url)
      |> SimpleJSON.try_decode()
    end)

    sidebar_items_json = Task.async(fn ->
      html
      |> grab_json(["sidebar_items"], url)
      |> SimpleJSON.try_decode()
    end)
   
    pkg = pkg
      |> Map.put("docs_config_json", Task.await(docs_config_json))
      |> Map.put("search_items_json", Task.await(search_items_json))
      |> Map.put("sidebar_items_json", Task.await(sidebar_items_json))
      |> cleanup_result()

    Hex.update_package(package, pkg)
  end

  def follow_browser_redirect(html, url) do
    {:ok, document} = Floki.parse_document(html)
    rd = Floki.attribute(document, "meta", "content")
      |> Enum.at(0, "")
      |> String.split("; url=")
      |> Enum.at(1, "") 
    Req.get!(url <> rd).body
  end

  def grab_html(url) do
    {:ok, document} = Req.get!(url).body
        |> Floki.parse_document()

    document
  end

  def grab_json(html, fnames, url) do
    Floki.attribute(html, "script", "src")
      |> Enum.filter(fn str -> 
        Enum.any?(fnames, fn fname ->
          String.contains?(str, fname) 
        end)
      end)
      |> Enum.at(0, nil)
      |> fetch_json(url)
  end

  defp fetch_json(nil, _), do: nil
  defp fetch_json(path, url) do
    Req.get!(URI.encode(url <> path)).body
  end

  def cleanup_result(pkg) do
    p = Map.take(pkg, ~w(
      docs_html_url
      downloads
      html_url
      latest_release
      latest_stable_version
      version
      meta
      name
      search_items_json
      sidebar_items_json
      docs_config_json
      updated_at
    ))
    |> Map.put("downloads_all", get_in(pkg, ["downloads", "all"]) )
    |> Map.put("downloads_day", get_in(pkg, ["downloads", "day"]) )
    |> Map.put("downloads_recent", get_in(pkg, ["downloads", "recent"]))
    |> Map.put("downloads_week", get_in(pkg, ["downloads", "week"]))
    |> Map.delete("downloads")
    |> Map.put_new("last_pulled", DateTime.utc_now())
    |> Map.put("latest_docs_url", latest_docs_url(pkg))

    sidebars = Map.get(p, "sidebar_items_json")
    sidebars = 
      cond do
        is_list(sidebars) -> %{weird: sidebars}
        is_binary(sidebars) -> %{unparsed: sidebars}
        true -> sidebars
      end

    p = Map.put(p, "sidebar_items_json", sidebars)

    docs_config = Map.get(p, "docs_config_json")
    docs_config = 
      cond do
        is_map(docs_config) -> [docs_config]
        is_binary(docs_config) -> [%{unparsed: docs_config}]
        true -> docs_config
      end

    p = Map.put(p, "docs_config_json", docs_config)

    search = Map.get(p, "search_items_json")
    search = 
      cond do
        is_map(search) -> [%{docs: search}]
        is_binary(search) -> [%{unparsed: search}]
        true -> search
      end
    
    p = Map.put(p, "search_items_json", search)

    if p["latest_stable_version"] == nil || p["latest_stable_version"] == "" do
      Map.put(p, "latest_stable_version", get_version(p))
    else 
      p
    end
  end

  defp get_version(%{"docs_config_json" => docs}) when not is_nil(docs) do
    docs
    |> Enum.at(0, %{})
    |> Map.get("version", "")
    |> String.replace("v", "")
  end
  defp get_version(_p), do: nil

  defp latest_docs_url(pkg) do
    latest_stable_version = Map.get(pkg, "latest_stable_version", nil)


    if is_map(latest_stable_version) do
      latest_stable_version["docs_url"]
    else
      (pkg["releases"] || [])
      |> Enum.filter(fn k -> k["has_docs"] end)
      |> Enum.sort_by(fn k -> 
        {:ok, dt,_} = DateTime.from_iso8601(k["inserted_at"]) 
        dt
      end, :asc)
      |> Enum.at(0, %{})
      |> Map.get("docs_url", nil)
    end
  end
end
