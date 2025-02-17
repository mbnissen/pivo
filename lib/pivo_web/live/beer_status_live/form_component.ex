defmodule PivoWeb.BeerStatusLive.FormComponent do
  @moduledoc false
  use PivoWeb, :live_component

  alias Pivo.Availibility

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
    params = transform_params(beer_status_params)
    changeset = Availibility.change_beer_status(socket.assigns.beer_status, params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"beer_status" => beer_status_params}, socket) do
    save_beer_status(socket, socket.assigns.action, beer_status_params)
  end

  defp save_beer_status(socket, :new, beer_status_params) do
    params = transform_params(beer_status_params)

    case Availibility.create_beer_status(params) do
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

  defp transform_params(%{"is_available" => "available"} = params) do
    Map.put(params, "is_available", true)
  end

  defp transform_params(%{"is_available" => "not_available"} = params) do
    Map.put(params, "is_available", false)
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

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
        <.input field={@form[:comment]} type="textarea" placeholder="Add comment if you want" />
        <ul class="grid w-full gap-6 md:grid-cols-2">
          <li>
            <input
              type="radio"
              id="vino-available"
              name={@form[:is_available].name}
              value="available"
              class="hidden peer"
              checked={@form[:is_available].value}
              required
            />
            <label
              for="vino-available"
              class="inline-flex items-center justify-between w-full p-5 text-gray-500 bg-white border border-gray-200 rounded-lg cursor-pointer peer-checked:border-green-600 border-2"
            >
              <div class="w-full font-semibold">In stock</div>
              <img src={~p"/images/beer.png"} width="36" />
            </label>
          </li>
          <li>
            <input
              type="radio"
              id="vino-not-available"
              name={@form[:is_available].name}
              value="not_available"
              checked={!@form[:is_available].value}
              class="hidden peer"
            />
            <label
              for="vino-not-available"
              class="inline-flex items-center justify-between w-full p-5 text-gray-500 bg-white border border-gray-200 rounded-lg cursor-pointer peer-checked:border-red-600 border-2"
            >
              <div class="w-full font-semibold">Out of stock</div>
              <img src={~p"/images/no_beer.png"} width="36" />
            </label>
          </li>
        </ul>
        <:actions>
          <.button phx-value-fuck="this" phx-disable-with="Saving...">Save Beer status</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end
