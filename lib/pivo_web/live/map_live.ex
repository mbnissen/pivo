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
    kihoskh = %{
      name: "Kihoskh",
      logo: "kihoskh_logo.avif",
      website: "https://www.kihoskh.dk",
      lat: 55.66644759532798,
      lng: 12.55304832864403,
      vino: true,
      style: "Can"
    }

    rallys = %{
      name: "Rallys",
      logo: "rallys_logo.png",
      description: "Best place in Copenhagen. Best beers and Czech pilsner on side pull tap.",
      website: "https://www.rallys.dk",
      lat: 55.64846734279557,
      lng: 12.532315540117958,
      vino: true,
      style: "Can"
    }

    peders = %{
      name: "Peders",
      logo: "peders_logo.png",
      description: "Best place in Copenhagen. Best beers and Czech pilsner on side pull tap.",
      lat: 55.6792037555745,
      lng: 12.569022168955275,
      vino: true,
      style: "Side pull"
    }

    taphouse = %{
      name: "Taphouse",
      logo: "taphouse_logo.png",
      description:
        "The biggest selection of beers in Denmark. 61 taps and 200+ bottles. 5 stars when Jacob is there",
      lat: 55.67623174183128,
      lng: 12.571488122353864,
      vino: true,
      style: "Side pull"
    }

    mikkeller_bottle_shop = %{
      name: "Mikkeller & Friends Bottle Shop",
      logo: "mikkeller_bottle_shop_logo.png",
      description: "The best bottle shop in Copenhagen. 1000+ beers",
      lat: 55.683796786548264,
      lng: 12.569227882377323,
      vino: false,
      style: "Can"
    }

    locations = [peders, taphouse, rallys, mikkeller_bottle_shop, kihoskh]

    access_token =
      Application.get_env(:pivo, :mapbox)
      |> Keyword.get(:access_token)

    {:ok, assign(socket, access_token: access_token, locations: locations)}
  end
end
