defmodule PivoWeb.BeerStatusLive.Index do
  @moduledoc false
  use PivoWeb, :live_view

  alias Pivo.Availibility
  alias Pivo.Availibility.BeerStatus

  @impl true
  def mount(_params, _session, socket) do
    beer_shops =
      Enum.reduce(Availibility.list_beer_shops(), %{}, fn beer_shop, acc -> Map.put(acc, beer_shop.id, beer_shop) end)

    {:ok,
     socket
     |> stream(:beer_status_collection, Availibility.list_beer_status())
     |> assign(:beer_shops, beer_shops)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Vino status")
    |> assign(:beer_status, %BeerStatus{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Vino status")
    |> assign(:beer_status, nil)
  end

  @impl true
  def handle_info({PivoWeb.BeerStatusLive.FormComponent, {:saved, beer_status}}, socket) do
    {:noreply, stream_insert(socket, :beer_status_collection, beer_status, at: 0)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 max-w-lg mx-auto">
      <div id="beer_status" phx-update="stream">
        <div
          :for={{dom_id, beer_status} <- @streams.beer_status_collection}
          class="flex border-b border-gray-200 py-4"
          id={dom_id}
        >
          <div class="flex-none w-14">
            <img
              src={~p"/images/#{@beer_shops[beer_status.beer_shop_id].logo}"}
              class="w-12 h-12 rounded-full"
            />
          </div>
          <div class="flex-1">
            <span class="pt-1 font-semibold">
              {@beer_shops[beer_status.beer_shop_id].name}
            </span>
            <div :if={beer_status.comment} class="text-sm text-zinc-800 mb-2">
              <p>{beer_status.comment}</p>
            </div>
            <div class="text-xs text-zinc-500 pt-1">
              {Timex.from_now(beer_status.inserted_at)}
              <span :if={beer_status.username}>- {beer_status.username}</span>
            </div>
          </div>
          <div class="pt-1 flex flex-none w-12 justify-end">
            <img :if={beer_status.is_available} src="/images/beer.png" class="w-8 h-8" />
            <img :if={!beer_status.is_available} src="/images/no_beer.png" class="w-8 h-8" />
          </div>
        </div>
      </div>
      <.modal
        :if={@live_action in [:new, :edit]}
        id="beer_status-modal"
        show
        on_cancel={JS.patch(~p"/beer_status")}
      >
        <.live_component
          module={PivoWeb.BeerStatusLive.FormComponent}
          id={@beer_status.id || :new}
          title={@page_title}
          action={@live_action}
          beer_status={@beer_status}
          patch={~p"/beer_status"}
        />
      </.modal>
    </div>
    """
  end
end
