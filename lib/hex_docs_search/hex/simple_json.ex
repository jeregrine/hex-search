defmodule HexDocsSearch.Hex.SimpleJSON do
  require Logger
  def try_decode(nil), do: nil
  def try_decode(""), do: ""
  def try_decode(str) do
    str = cleanup(str)
    try do
      Jason.decode!(str)
    rescue
      e ->
        Logger.error(e)
        try do
          decode!(str)
        rescue
          e ->
            Logger.error(e)
            str
        end
    end
  end

  def cleanup(<<"<", _::binary>>), do: "" # Html or something
  def cleanup(nil), do: ""
  def cleanup(str) do
    str = str
    |> String.trim()
    |> String.trim_leading("searchNodes=") 
    |> String.trim_leading("searchData = ")
    |> String.trim_leading("searchData=")
    |> String.trim_leading("searchNodes = ") 
    |> String.trim_leading("sidebarNodes=") 
    |> String.trim_leading("sidebarNodes = ") 
    |> String.trim_leading("var versionNodes = ")
    |> String.trim_leading("var versionNodes=")
    |> String.trim_leading("versionNodes=")
    |> String.trim_leading("versionNodes = ")
    |> String.trim_trailing(";\nfillSidebarWithNodes(sidebarNodes);")
    |> String.trim_trailing(";")
    |> String.trim()

    case Regex.named_captures(~r/\<\<(?<binary>[\d\,\s]*)...\>\>/, str) do
      nil -> str
      %{"binary" => bin} -> 
        ha = bin
          |> String.trim()
          |> String.trim_trailing(",")
          |> String.split(", ")
          |> Enum.map(fn str -> <<String.to_integer(str)>> end)
          |> Enum.join("")

        Regex.replace(~r/\<\<([\d\,\s]*)...\>\>/, str, "\""<>ha<>"\"")
    end
  end

  @doc """
  ## Examples

      iex> SimpleJSON.decode!("[{key:\\"val\\", blah:1},{key:\\"val\\", blah:2}]")
      [%{"key" => "val", "blah" => 1}, %{"key" => "val", "blah" => 2}]

      iex> SimpleJSON.decode!("[{key:\\"val\\", blah:1, extras:[{key:\\"val\\", blah:2}]}]")
      [%{"key" => "val", "blah" => 1, "extras" => [%{"key" => "val", "blah" => 2}]}]
  
  """
  def decode!(str) do
    str
    |> tokens()
    |> parse()
  end
  
  defp tokens(str) do
    Regex.scan(~r/("(\\.|[^"])*"|\[|\]|,|\d+|\{|\}|\:|[a-zA-Z0-9_]+)/, str)
  end

  defp parse(nil), do: nil
  defp parse(""), do: nil
  defp parse([]), do: nil
  defp parse([["[", "["] | rest]) do
    parse(rest, [])
  end
  defp parse([["{", "{"] | rest]) do
    parse(rest, [%{}])
  end
  defp parse([["}", "}"]], acc) do
    acc
  end
  defp parse([["]", "]"]], acc) do
    acc
    |> Enum.reverse()
  end
  defp parse([["]", "]"] | more], acc) do
    {acc, more}
  end

  defp parse([["{", "{"] | rest], acc) do
    parse(rest, [%{} | acc])
  end
  defp parse([["}", "}"] | rest], acc) do
    parse(rest, acc)
  end
  defp parse([[",", ","] | rest], acc) do
    parse(rest, acc)
  end
  defp parse([[key, key], [":", ":"], ["[", "["] | rest], [map | acc]) when is_map(map) do
    {array, rest2} = parse(rest, [])
    parse(rest2, [Map.put(map, String.replace(key, "\"", ""), array) | acc])
  end
  defp parse([[key, key, _], [":", ":"], ["[", "["] | rest], [map | acc]) when is_map(map) do
    {array, rest2} = parse(rest, [])
    parse(rest2, [Map.put(map, String.replace(key, "\"", ""), array) | acc])
  end

  defp parse([[key, key, _], [":", ":"], [val, val, _] | rest], [map | acc]) when is_map(map) do
    parse(rest, [Map.put(map, String.replace(key, "\"", ""), String.replace(val, "\"", "")) | acc])
  end
  defp parse([[key, key, _], [":", ":"], [val, val] | rest], [map | acc]) when is_map(map) do
    parse(rest, [Map.put(map, String.replace(key, "\"", ""), type(val)) | acc])
  end
  defp parse([[key, key], [":", ":"], [val, val, _] | rest], [map | acc]) when is_map(map) do
    parse(rest, [Map.put(map, key, String.replace(val, "\"", "")) | acc])
  end
  defp parse([[key, key], [":", ":"], [val, val] | rest], [map | acc]) when is_map(map) do
    parse(rest, [Map.put(map, key, type(val)) | acc])
  end

  defp type("\"\""), do: ""
  defp type(int) do
    try do
      String.to_integer(int)
    catch
      _, _ -> 
        int
    end
  end
end
