defmodule Pivo.UntappdBeerScraper do
  @moduledoc false
  use GenServer

  alias Pivo.Availibility
  alias Pivo.Scrapers.Untappd

  require Logger

  # 5 minutes
  @interval 300_000

  def start(opts) do
    GenServer.start(__MODULE__, opts, name: {:global, opts[:name]})
  end

  # Server Callbacks
  @impl true
  def init(opts) do
    send(self(), :update)
    {:ok, opts}
  end

  @impl true
  def handle_info(:update, state) do
    update_vino_status(state)

    schedule_next_update()
    {:noreply, state}
  end

  defp schedule_next_update do
    Process.send_after(self(), :update, @interval)
  end

  defp update_vino_status(state) do
    name = Keyword.get(state, :name)
    beer_shop_id = Keyword.get(state, :beer_shop_id)
    url = Keyword.get(state, :url)
    vino_tap_number = Keyword.get(state, :vino_tap_number)

    case Untappd.get_vino_status(url, vino_tap_number) do
      {:ok, %{vino: vino, replacement: replacement}} ->
        Logger.info("Vino status for #{name}: #{inspect(vino)} - Replacement: #{inspect(replacement)}")

        Availibility.update_beer_status(beer_shop_id, vino, replacement)

      {:error, reason} ->
        Logger.info("Error: #{inspect(reason)}")
    end
  end
end
