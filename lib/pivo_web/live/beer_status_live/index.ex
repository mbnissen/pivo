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

  defp apply_action(socket, :new, params) do
    socket
    |> assign(:page_title, "Report Vino")
    |> assign(:beer_status, %BeerStatus{is_available: true, beer_shop_id: params["beer_shop_id"]})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Latest reports")
    |> assign(:beer_status, nil)
  end

  @impl true
  def handle_info({PivoWeb.BeerStatusLive.FormComponent, {:saved, beer_status}}, socket) do
    {:noreply, stream_insert(socket, :beer_status_collection, beer_status, at: 0)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <ul
        class="list bg-base-100 max-w-xl rounded-box shadow-md mx-auto"
        id="beer_status"
        phx-update="stream"
      >
        <li
          :for={{dom_id, beer_status} <- @streams.beer_status_collection}
          class="list-row"
          id={dom_id}
        >
          <div>
            <img
              src={~p"/images/#{@beer_shops[beer_status.beer_shop_id].logo}"}
              class="size-14 rounded-full"
            />
          </div>
          <div class="list-col-grow">
            <div class="text-lg">{@beer_shops[beer_status.beer_shop_id].name}</div>
            <div
              :if={beer_status.comment}
              class="text-sm mb-2"
            >
              <p>{beer_status.comment}</p>
            </div>
            <div class="text-xs pt-1 opacity-60">
              {Timex.from_now(beer_status.inserted_at)}
              <span :if={
                beer_status.username
              }>- {beer_status.username}</span>
            </div>
          </div>
            <div class="pt-1 flex flex-none w-12 justify-end">
              <img
              :if={beer_status.is_available}
              src="/images/beer.png"
              class="w-8 h-8"
            />
              <img
              :if={!beer_status.is_available}
              src="/images/no_beer.png"
              class="w-8 h-8"
            />
            </div>
        </li>
      </ul>
      <dialog :if={@live_action in [:new, :edit]} id="my_modal" class="modal modal-open">
        <div class="modal-box">
          <form method="dialog">
            <.link navigate={~p"/beer_status"}>
            <button class="btn btn-circle btn-ghost absolute right-4 top-4">✕</button>
            </.link>
          </form>
          <.live_component
            module={PivoWeb.BeerStatusLive.FormComponent}
            id={@beer_status.id || :new}
            title={@page_title}
            action={@live_action}
            beer_status={@beer_status}
            patch={~p"/beer_status"}
          />
        </div>
      </dialog>
    </Layouts.app>
    """
  end
end
