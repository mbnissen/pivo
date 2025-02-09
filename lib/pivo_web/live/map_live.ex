defmodule PivoWeb.MapLive do
  use PivoWeb, :live_view

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
    peders = %{
      name: "Peders",
      description: "Best place in Copenhagen. Best beers and Czech pilsner on side pull tap.",
      rating: 5,
      lat: 55.6792037555745,
      lng: 12.569022168955275
    }

    taphouse = %{
      name: "Taphouse",
      description:
        "The biggest selection of beers in Denmark. 61 taps and 200+ bottles. 5 stars when Jacob is there",
      rating: 4,
      lat: 55.67623174183128,
      lng: 12.571488122353864
    }

    locations = [peders, taphouse]

    access_token =
      Application.get_env(:pivo, :mapbox)
      |> Keyword.get(:access_token)

    {:ok, assign(socket, access_token: access_token, locations: locations)}
  end
end
