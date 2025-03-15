defmodule Pivo.Scrapers.Taphouse do
  @moduledoc false
  @url "https://www.taphouse.dk"

  def get_vino_status do
    case fetch_beer_list() do
      {:ok, beer_list} ->
        case Enum.find(beer_list, &(Map.get(&1, :name) === "Vinohradská 11")) do
          nil ->
            replacement = Enum.find(beer_list, &(Map.get(&1, :number) === "23"))
            {:ok, %{vino: nil, replacement: replacement}}

          vino ->
            {:ok, %{vino: vino, replacement: nil}}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp fetch_beer_list do
    with {:ok, %Req.Response{body: body}} <- Req.get(@url),
         {:ok, html} <- Floki.parse_document(body) do
      {:ok, parse_beer_list(html)}
    end
  end

  defp parse_beer_list(html) do
    html
    |> Floki.find("#beerTable")
    |> Floki.find("tr")
    |> Enum.map(&parse_beer/1)
    |> Enum.reject(&is_nil/1)
  end

  defp parse_beer(beer) do
    case get_column_text(beer, 3) do
      "" ->
        nil

      name ->
        [size, price] = beer |> get_column_text(7) |> String.split(" ")

        %{
          number: get_column_text(beer, 1),
          brewery: beer |> get_column_text(2) |> String.trim(),
          name: name |> String.slice(1..-3//1) |> String.trim(),
          style: get_column_text(beer, 4),
          country: get_column_text(beer, 5),
          abv: get_column_text(beer, 6),
          price: price,
          size: size
        }
    end
  end

  defp get_column_text(beer, column) do
    beer
    |> Floki.find("td:nth-child(#{column})")
    |> Floki.text()
  end
end
