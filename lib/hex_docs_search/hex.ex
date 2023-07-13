defmodule HexDocsSearch.Hex do
  @moduledoc """
  The Hex context.
  """

  import Ecto.Query, warn: false
  alias HexDocsSearch.Repo

  alias HexDocsSearch.Hex.{Package, PackageIndex}

  @doc """
  Returns the list of packages.

  ## Examples

      iex> list_packages()
      [%Package{}, ...]

  """
  def list_packages do
    Repo.all(Package)
  end

  def list_packages(limit) do
    from(p in Package, limit: ^limit, order_by: [desc: p.downloads_all])
    |> Repo.all()
  end


  def search_packages(term, limit \\ 25) do
    term = 
      term
      |> String.trim()
      |> String.trim_trailing(".")

    term_quoted = "\"#{term}\"" 
      |> String.replace(" " , "+")


    unioned = from(i in PackageIndex, 
      select: %{ i | 
        function_rank: fragment("bm25(packages_index, 10.0, 5.0, 1.0)"),
        module_rank: fragment("bm25(packages_index, 5.0, 10.0, 1.0)"),
      },
      where: fragment("packages_index MATCH ?", ^term_quoted)
    )

    preload_query = from(p in Package, select: [:id, :name, :latest_stable_version, :docs_html_url])

    q = from(i in subquery(unioned), 
      join: p in assoc(i, :package),
      select: %{ i |
        rank: fragment("
                        CASE
                          WHEN (lower(?) = lower(?) and lower(?) = lower(?)) THEN -5000.0
                          WHEN ? = ? and (lower(?) = lower(?) or lower(?) = lower(?)) THEN -2000.0
                          WHEN ? = ? and ? = ? and instr(lower(?), lower(?)) = 1 and abs(length(?) - length(?)) < 3 THEN -1000.0
                          WHEN ? <> 'module' and instr(lower(?), lower(?)) = 1 and abs(length(?) - length(?)) < 3 THEN -500.0
                          WHEN instr(lower(?), lower(?)) = 1 THEN -30.0 
                          WHEN instr(lower(?), lower(?)) = 1 THEN -20.0 
                          ELSE 0.0
                        END + ?  + ? + ?",
          p.name, ^term, 
          i.title, ^term, 

          i.type, "module",
          p.name, ^term, 
          i.title, ^term, 

          i.type, "module",
          p.name, ^term, 
          i.title, ^term, 
          i.title, ^term, 

          i.type,
          i.title, ^term,
          i.title, ^term,

          p.name, ^term,
          i.title, ^term,
          "function_rank", "module_rank", i.rank
        )
      }
    )

    q2 = from(i in subquery(q), 
      select: %PackageIndex{
          id: i.id,
          title: i.title,
          type: i.type,
          package_id: i.package_id,
          ref: i.ref,
          rank: i.rank
      },
      order_by: [asc: i.rank],
      limit: ^limit
    )

    q2
    |> Repo.all()
    |> Repo.preload(package: preload_query)
  end

  @doc """
  Gets a single package by id or name

  Raises `Ecto.NoResultsError` if the Package does not exist.

  ## Examples

      iex> get_package!(123)
      %Package{}

      iex> get_package!(456)
      ** (Ecto.NoResultsError)

      iex> get_package!("ecto")
      %Package{name: "Ecto"}

      iex> get_package!("elixir2")
      ** (Ecto.NoResultsError)
  """
  def get_package!(id) when is_integer(id), do: Repo.get!(Package, id)

  @doc """
  Gets a single package by id or name

  returns nil when none is found

  ## Examples

      iex> get_package!(123)
      %Package{}

      iex> get_package!(456)
      nil

      iex> get_package!("ecto")
      %Package{name: "Ecto"}

      iex> get_package!("elixir2")
      nil
  """
  def get_package(name) when is_binary(name), do: Repo.get_by(Package, name: name)

  @doc """
  Creates a package.

  ## Examples

      iex> create_package(%{field: value})
      {:ok, %Package{}}

      iex> create_package(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_package(attrs \\ %{}) do
    with {:ok, package } <- Repo.insert(Package.changeset(%Package{}, attrs)) do
      create_package_index(package)

      {:ok, package}
    end
  end

  @doc """
  Indexes a Package

  ## Examples

      iex> create_package_index(%Package{})
      {:ok, %PackageIndex{}}

      iex> create_package_index(nil)
      {:error, %Ecto.Changeset{}}

  """
  def create_package_index(package) do
    for doc <- get_docs(package.search_items_json) do
      %PackageIndex{}
      |> PackageIndex.changeset(doc)
      |> Ecto.Changeset.put_assoc(:package, package)
      |> Repo.insert()
    end
  end

  def get_docs(nil), do: []
  def get_docs([%{"unparsed" => _}]), do: []
  def get_docs([%{"items" => docs}]), do: docs
  def get_docs([%{"weird" => docs}]), do: docs
  def get_docs(docs) when is_list(docs), do: docs

  @doc """
  Updates a package.

  ## Examples

      iex> update_package(package, %{field: new_value})
      {:ok, %Package{}}

      iex> update_package(package, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_package(%Package{} = package, attrs) do
    with {:ok, package} <- Repo.update(Package.changeset(package, attrs)) do
      create_package_index(package)
      {:ok, package}
    end
  end

  @doc """
  Updates a package index.

  ## Examples

      iex> update_package_index(packages_index, %{field: new_value})
      {:ok, %PackageIndex{}}

      iex> update_package_index(package_index, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_package(%Package{} = package) do
    Repo.delete_all(PackageIndex, where: [package_id: package.id])
    create_package_index(package)
  end

  @doc """
  Deletes a package.

  ## Examples

      iex> delete_package(package)
      {:ok, %Package{}}

      iex> delete_package(package)
      {:error, %Ecto.Changeset{}}

  """
  def delete_package(%Package{} = package) do
    with {:ok, package} <- Repo.delete(package) do
      Repo.delete_all(PackageIndex, where: [package_id: package.id])
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking package changes.

  ## Examples

      iex> change_package(package)
      %Ecto.Changeset{data: %Package{}}

  """
  def change_package(%Package{} = package, attrs \\ %{}) do
    Package.changeset(package, attrs)
  end
end
