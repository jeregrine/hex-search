defmodule HexDocsSearch.Repo do
  use Ecto.Repo,
    otp_app: :hex_docs_search,
    adapter: Ecto.Adapters.SQLite3
end
