defmodule Pivo.Scrapers.Untappd do
  @moduledoc false

  def get_vino_status(url, vino_tap_number) do
    case fetch_beer_list(url) do
      {:ok, beer_list} ->
        case Enum.find(beer_list, &(Map.get(&1, :name) === "Vinohradská 11")) do
          nil ->
            replacement = Enum.find(beer_list, &(Map.get(&1, :number) === vino_tap_number))
            {:ok, %{vino: nil, replacement: replacement}}

          vino ->
            {:ok, %{vino: vino, replacement: nil}}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp fetch_beer_list(url) do
    with {:ok, %Req.Response{body: body}} <- Req.get(url),
         {:ok, html} <- Floki.parse_document(body) do
      {:ok, parse_beer_list(html)}
    end
  end

  defp parse_beer_list(html) do
    html
    |> Floki.find(".menu-section-list")
    |> Floki.find(".menu-item")
    |> Enum.map(&parse_beer/1)
  end

  defp parse_beer(beer) do
    header = Floki.find(beer, "h5")
    subheader = Floki.find(beer, "h6")

    [number, name] =
      case header
           |> Floki.find("a")
           |> Floki.text()
           |> String.split("\n")
           |> Enum.map(&String.trim/1) do
        [_, number, name] -> [String.replace(number, ".", ""), name]
        [_, name] -> [nil, name]
      end

    style = header |> Floki.find("em") |> Floki.text() |> String.trim()

    brewery =
      subheader
      |> Floki.find("a")
      |> Floki.text()
      |> String.trim()

    %{
      number: number,
      brewery: brewery,
      name: name,
      style: style
    }
  end
end
