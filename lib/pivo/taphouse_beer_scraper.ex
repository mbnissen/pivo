defmodule Pivo.BeerScraper do
  @moduledoc false
  use GenServer

  alias Pivo.Availibility
  alias Pivo.Scrapers.Taphouse

  require Logger

  @taphouse_id "5b37fbb7-d03b-4536-b8dc-34ee9b3e7fc3"
  # 5 minutes
  @interval 300_000

  def start(opts \\ []) do
    GenServer.start(__MODULE__, opts, name: __MODULE__)
  end

  # Server Callbacks
  @impl true
  def init(opts) do
    send(self(), :update)
    {:ok, opts}
  end

  @impl true
  def handle_info(:update, state) do
    update_vino_status()

    schedule_next_update()
    {:noreply, state}
  end

  defp schedule_next_update do
    Process.send_after(self(), :update, @interval)
  end

  defp update_vino_status do
    case Taphouse.get_vino_status() do
      {:ok, %{vino: vino, replacement: replacement}} ->
        Logger.info("Vino status for Taphouse: #{inspect(vino)} - Replacement: #{inspect(replacement)}")

        Availibility.update_beer_status(@taphouse_id, vino, replacement)

      {:error, reason} ->
        Logger.info("Error: #{inspect(reason)}")
    end
  end
end
