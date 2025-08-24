defmodule PivoWeb.MapLive do
  @moduledoc false
  use PivoWeb, :live_view

  alias Pivo.Availibility

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="h-screen w-screen">
        <div
          id="map"
          class="h-screen w-screen"
          phx-hook="MapHook"
          data-access-token={@access_token}
          data-locations={Jason.encode!(@locations)}
        />
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    locations =
      Enum.map(Availibility.list_beer_shops(), fn beer_shop ->
        latest_status =
          Availibility.get_latest_beer_status_by_shop_id(beer_shop.id)

        latest_update =
          case Map.get(latest_status || %{}, :inserted_at, nil) do
            nil -> "No updates"
            date -> Timex.from_now(date)
          end

        %{
          id: beer_shop.id,
          name: beer_shop.name,
          lat: beer_shop.lat,
          lng: beer_shop.lng,
          style: beer_shop.style,
          logo: beer_shop.logo,
          vino: Map.get(latest_status || %{}, :is_available, false),
          canning_date: Map.get(latest_status || %{}, :canning_date),
          latest_update: latest_update,
          latest_update_comment: Map.get(latest_status || %{}, :comment, "")
        }
      end)

    access_token =
      :pivo
      |> Application.get_env(:mapbox)
      |> Keyword.get(:access_token)

    {:ok, assign(socket, access_token: access_token, locations: locations)}
  end
end
