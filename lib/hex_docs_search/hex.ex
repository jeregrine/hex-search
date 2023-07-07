defmodule HexDocsSearch.Hex do
  @moduledoc """
  The Hex context.
  """

  import Ecto.Query, warn: false
  alias HexDocsSearch.Repo

  alias HexDocsSearch.Hex.Package

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
    %Package{}
    |> Package.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a package.

  ## Examples

      iex> update_package(package, %{field: new_value})
      {:ok, %Package{}}

      iex> update_package(package, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_package(%Package{} = package, attrs) do
    package
    |> Package.changeset(attrs)
    |> Repo.update()
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
    Repo.delete(package)
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
