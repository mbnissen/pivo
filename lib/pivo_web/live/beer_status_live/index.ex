defmodule PivoWeb.BeerStatusLive.Index do
  use PivoWeb, :live_view

  alias Pivo.Availibility
  alias Pivo.Availibility.BeerStatus

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :beer_status_collection, Availibility.list_beer_status())}
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
  def handle_event("delete", %{"id" => id}, socket) do
    beer_status = Availibility.get_beer_status!(id)
    {:ok, _} = Availibility.delete_beer_status(beer_status)

    {:noreply, stream_delete(socket, :beer_status_collection, beer_status)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4">
      <.table id="beer_status" rows={@streams.beer_status_collection}>
        <:col :let={{_id, beer_status}} label="Username">{beer_status.username}</:col>
        <:col :let={{_id, beer_status}} label="Is available">{beer_status.is_available}</:col>
        <:col :let={{_id, beer_status}} label="Beer shop">{beer_status.beer_shop_id}</:col>
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
