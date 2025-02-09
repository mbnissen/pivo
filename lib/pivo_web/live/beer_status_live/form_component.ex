defmodule PivoWeb.BeerStatusLive.FormComponent do
  use PivoWeb, :live_component

  alias Pivo.Availibility

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>{@title}</.header>

      <.simple_form
        for={@form}
        id="beer_status-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:beer_shop_id]}
          type="select"
          label="Beer shop"
          options={@beer_shops |> Enum.map(&{&1.name, &1.id})}
        />
        <.input field={@form[:username]} type="text" label="Username (optional)" />
        <.input field={@form[:is_available]} type="checkbox" label="Is available?" value={true} />
        <:actions>
          <.button phx-value-fuck="this" phx-disable-with="Saving...">Save Beer status</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{beer_status: beer_status} = assigns, socket) do
    beer_shops = Availibility.list_beer_shops()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:beer_shops, beer_shops)
     |> assign_new(:form, fn ->
       to_form(Availibility.change_beer_status(beer_status))
     end)}
  end

  @impl true
  def handle_event("validate", %{"beer_status" => beer_status_params}, socket) do
    changeset = Availibility.change_beer_status(socket.assigns.beer_status, beer_status_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"beer_status" => beer_status_params}, socket) do
    dbg(beer_status_params)
    save_beer_status(socket, socket.assigns.action, beer_status_params)
  end

  defp save_beer_status(socket, :new, beer_status_params) do
    case Availibility.create_beer_status(beer_status_params) do
      {:ok, beer_status} ->
        notify_parent({:saved, beer_status})

        {:noreply,
         socket
         |> put_flash(:info, "Beer status created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
