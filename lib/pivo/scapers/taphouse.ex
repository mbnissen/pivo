defmodule Pivo.Scrapers.Taphouse do
  @moduledoc false
  @url "https://www.taphouse.dk"

  def get_vino_status do
    case fetch_beer_list() do
      {:ok, beer_list} ->
        case Enum.find(beer_list, &(Map.get(&1, :title) === "Vinohradská 11")) do
          nil ->
            replacement = Enum.find(beer_list, &(Map.get(&1, :number) === "23"))
            {:ok, %{vino: nil, replacement: replacement}}

          vino ->
            {:ok, %{vino: vino}}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp fetch_beer_list do
    case Req.get(@url) do
      {:ok, %Req.Response{body: body}} ->
        {:ok, parse_beer_list(body)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse_beer_list(html) do
    # Use Floki for HTML parsing
    html
    |> Floki.find("#beerTable")
    |> Floki.find("tr")
    |> Enum.map(&parse_beer/1)
    # Remove nil values
    |> Enum.reject(&is_nil/1)
  end

  defp parse_beer(beer) do
    case get_column_text(beer, 3) do
      "" ->
        nil

      title ->
        [size, price] = beer |> get_column_text(7) |> String.split(" ")

        %{
          number: get_column_text(beer, 1),
          brewery: get_column_text(beer, 2),
          title: String.slice(title, 0..-3//1),
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
