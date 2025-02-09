defmodule PivoWeb.MapLive do
  use PivoWeb, :live_view

  alias Pivo.Availibility

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-screen w-screen">
      <div
        id="map"
        class="h-screen w-screen"
        phx-hook="MapHook"
        data-access-token={@access_token}
        data-locations={Jason.encode!(@locations)}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    locations = Availibility.list_beer_shops()

    access_token =
      Application.get_env(:pivo, :mapbox)
      |> Keyword.get(:access_token)

    {:ok, assign(socket, access_token: access_token, locations: locations)}
  end
end
