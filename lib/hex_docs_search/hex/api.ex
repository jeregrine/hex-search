defmodule HexDocsSearch.Hex.API do
  def list!(params \\ %{}) do
    Req.get!("https://hex.pm/api/packages", params: params, auth: api_key()).body 
  end

  def get!(name, params \\ %{}) do
    Req.get!("https://hex.pm/api/packages/#{name}", params: params, auth: api_key()).body 
  end

  def api_key() do
    Application.get_env(:hex_docs_search, :api_key)
  end
end
