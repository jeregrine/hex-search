defmodule HexDocsSearch.Hex.InitialData do
  alias HexDocsSearch.Hex
  alias HexDocsSearch.Hex.{Package, PackageIndex, API}
  alias HexDocsSearch.Repo
  @special_packages [
    %{
      "name" => "elixir", 
      "version" => "",
      "docs_html_url" => "https://hexdocs.pm/elixir/",
      "meta" => %{},
      "html_url" => "https://elixir-lang.org/"
    },
    %{
      "name" => "eex", 
      "version" => "",
      "docs_html_url" => "https://hexdocs.pm/eex/",
      "meta" => %{},
      "html_url" => "https://elixir-lang.org/"
    },
    %{
      "name" => "ex_unit", 
      "version" => "",
      "docs_html_url" => "https://hexdocs.pm/ex_unit/",
      "meta" => %{},
      "html_url" => "https://elixir-lang.org/"
    },
    %{
      "name" => "iex", 
      "version" => "",
      "docs_html_url" => "https://hexdocs.pm/iex/",
      "meta" => %{},
      "html_url" => "https://elixir-lang.org/"
    },
    %{
      "name" => "logger", 
      "version" => "",
      "docs_html_url" => "https://hexdocs.pm/logger/",
      "meta" => %{},
      "html_url" => "https://elixir-lang.org/"
    },
    %{
      "name" => "mix", 
      "version" => "",
      "docs_html_url" => "https://hexdocs.pm/mix/",
      "meta" => %{},
      "html_url" => "https://elixir-lang.org/"
    }
  ]

  def initialize!() do
    fetch_packages!()
    |> Kernel.++(special_packages())
    |> Enum.map(fn d ->
      {:ok, package} = Hex.create_package(Map.take(d, ["name", "version", "docs_html_url", "meta", "html_url"]))
      {:ok, _p} = Hex.Hydrator.package(package, d)
    end)
  end

  def fetch_packages!() do
    Enum.reduce_while(1..500, [], fn page, acc ->
      data = API.list!(%{page: page})
      current = Enum.count(data)

      if current < 100 do
        {:halt, [data | acc]}
      else
        {:cont, [data | acc]}
      end
    end)
    |> List.flatten()
    |> Enum.filter(fn p -> p["docs_html_url"] end)
    |> tap(fn docs -> IO.puts("Got #{Enum.count(docs)} packages") end)
  end

  def special_packages!() do
    special_packages()
    |> Enum.map(fn d ->
      {:ok, package} = Hex.create_package(Map.take(d, ["name", "version", "docs_html_url", "meta", "html_url"]))
      {:ok, _p} = Hex.Hydrator.package(package, d)
    end)
  end

  def special_packages() do
    @special_packages
  end

  def reindex!() do
    Repo.delete_all(PackageIndex)
    for p <- Repo.all(Package) do
      Hex.create_package_index(p)
    end
  end
end
