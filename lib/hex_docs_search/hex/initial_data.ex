defmodule HexDocsSearch.Hex.InitialData do
  alias HexDocsSearch.Hex
  alias HexDocsSearch.Hex.{Package, PackageIndex}
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
    Path.expand("~/hex_docs.data")
    |> File.read!()
    |> :erlang.binary_to_term()
    |> Kernel.++(special_packages())
    |> Enum.map(fn d ->
      dbg(d)
      {:ok, package} = Hex.create_package(Map.take(d, ["name", "version", "docs_html_url", "meta", "html_url"]))
      {:ok, _p} = Hex.Hydrator.package(package, d)
    end)
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
