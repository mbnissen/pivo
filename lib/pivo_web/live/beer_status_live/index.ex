defmodule PivoWeb.BeerStatusLive.Index do
  use PivoWeb, :live_view

  alias Pivo.Availibility
  alias Pivo.Availibility.BeerStatus

  @impl true
  def mount(_params, _session, socket) do
    beer_shops =
      Availibility.list_beer_shops()
      |> Enum.reduce(%{}, fn beer_shop, acc -> Map.put(acc, beer_shop.id, beer_shop) end)

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
    |> assign(:page_title, "New beer status")
    |> assign(:beer_status, %BeerStatus{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing beer status")
    |> assign(:beer_status, nil)
  end

  @impl true
  def handle_info({PivoWeb.BeerStatusLive.FormComponent, {:saved, beer_status}}, socket) do
    {:noreply, stream_insert(socket, :beer_status_collection, beer_status)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4">
      <.table id="beer_status" rows={@streams.beer_status_collection}>
        <:col :let={{_id, beer_status}} label="Beer shop">
          <div class="flex gap-2">
            <img
              src={~p"/images/#{@beer_shops[beer_status.beer_shop_id].logo}"}
              class="w-8 h-8 rounded-full"
            />
            <span class="pt-1">
              {@beer_shops[beer_status.beer_shop_id].name}
            </span>
          </div>
        </:col>
        <:col :let={{_id, beer_status}} label="Available?">
          <img :if={beer_status.is_available} src="/images/beer.png" class="w-6 h-6" />
          <img :if={!beer_status.is_available} src="/images/no_beer.png" class="w-6 h-6" />
        </:col>
        <:col :let={{_id, beer_status}} label="By">{beer_status.username}</:col>
        <:col :let={{_id, beer_status}} label="When">
          {Calendar.strftime(beer_status.inserted_at, "%H:%M:%S - %d/%m - %Y")}
        </:col>
      </.table>

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
