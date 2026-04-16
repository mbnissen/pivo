defmodule PivoWeb.CheckinLive do
  @moduledoc false
  use PivoWeb, :live_view

  alias Pivo.Availibility

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case Availibility.get_beer_status(id) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Checkin not found")
         |> push_navigate(to: ~p"/beer_status")}

      beer_status ->
        beer_shop = Availibility.get_beer_shop(beer_status.beer_shop_id)
        url = url(socket, ~p"/checkin/#{beer_status.id}")
        share_text = build_share_text(beer_status, beer_shop)

        {:ok,
         socket
         |> assign(:beer_status, beer_status)
         |> assign(:beer_shop, beer_shop)
         |> assign(:share_url, url)
         |> assign(:share_text, share_text)
         |> assign(:page_title, "#{beer_shop.name} · Vino checkin")
         |> assign(:og_title, "#{vino_emoji(beer_status)} Vino at #{beer_shop.name}")
         |> assign(:og_description, og_description(beer_status, beer_shop))
         |> assign(:og_url, url)}
    end
  end

  defp build_share_text(%{is_available: true} = beer_status, beer_shop) do
    base = "🍻 Vinohradská 11 is on at #{beer_shop.name}"
    if beer_status.comment, do: "#{base} (#{beer_status.comment})", else: base
  end

  defp build_share_text(%{is_available: false} = beer_status, beer_shop) do
    base = "😢 No Vinohradská 11 at #{beer_shop.name} right now"
    if beer_status.comment, do: "#{base} — #{beer_status.comment}", else: base
  end

  defp og_description(beer_status, beer_shop) do
    parts = [build_share_text(beer_status, beer_shop)]
    parts = if beer_status.canning_date, do: parts ++ ["Canned on #{beer_status.canning_date}"], else: parts
    Enum.join(parts, " · ")
  end

  defp vino_emoji(%{is_available: true}), do: "🍻"
  defp vino_emoji(%{is_available: false}), do: "😢"

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-xl mx-auto p-4">
        <div class="card bg-base-100 shadow-lg border border-base-300">
          <div class="card-body items-center text-center gap-4">
            <img
              src={~p"/images/#{@beer_shop.logo}"}
              class="size-24 rounded-full"
              alt={@beer_shop.name}
            />
            <h1 class="text-2xl font-semibold">{@beer_shop.name}</h1>

            <div class="flex flex-col items-center gap-2">
              <img
                :if={@beer_status.is_available}
                src={~p"/images/beer.png"}
                class="w-16 h-16"
              />
              <img
                :if={!@beer_status.is_available}
                src={~p"/images/no_beer.png"}
                class="w-16 h-16"
              />
              <p class="text-lg font-medium">
                {if @beer_status.is_available,
                  do: "Vinohradská 11 is available!",
                  else: "Not available right now"}
              </p>
            </div>

            <p :if={@beer_status.comment} class="text-base opacity-80">
              {@beer_status.comment}
            </p>
            <p :if={@beer_status.canning_date} class="text-sm opacity-60">
              Canned on: {@beer_status.canning_date}
            </p>
            <p class="text-sm opacity-60">
              {Timex.from_now(@beer_status.inserted_at)}<span :if={@beer_status.username}>
                · {@beer_status.username}</span>
            </p>
          </div>
        </div>

        <div
          id="checkin-share"
          phx-hook="ShareHook"
          data-url={@share_url}
          data-text={@share_text}
          data-title={"Vino at #{@beer_shop.name}"}
          class="mt-6 flex flex-col gap-3"
        >
          <button
            type="button"
            data-share-native
            class="btn btn-primary w-full hidden"
          >
            <.icon name="hero-share" class="size-5" /> <span class="share-label">Share with friends</span>
          </button>

          <button
            type="button"
            data-share-copy
            class="btn btn-outline w-full"
          >
            <span data-copy-label>Copy link</span>
          </button>
        </div>

        <div class="mt-6 text-center">
          <.link navigate={~p"/beer_status"} class="link link-hover text-sm opacity-70">
            ← All reports
          </.link>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
