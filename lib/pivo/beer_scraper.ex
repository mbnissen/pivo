defmodule Pivo.BeerScraper do
  @moduledoc false
  use GenServer

  alias Pivo.Availibility
  alias Pivo.Scrapers.Taphouse

  require Logger

  @taphouse_id "5b37fbb7-d03b-4536-b8dc-34ee9b3e7fc3"

  # Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_current_beer_list do
    GenServer.call(__MODULE__, :get_beer_list)
  end

  # Server Callbacks
  @impl true
  def init(_opts) do
    # Schedule first scrape immediately
    send(self(), :scrape)

    # Schedule periodic scraping every hour
    schedule_next_scrape()

    {:ok, %{beer_list: []}}
  end

  @impl true
  def handle_info(:scrape, state) do
    # Perform the scraping
    scrape_vino_status()

    # Schedule next scrape
    schedule_next_scrape()

    # Update state with new beer list
    {:noreply, state}
  end

  # Private helper functions
  defp scrape_vino_status do
    case Taphouse.get_vino_status() do
      {:ok, nil} ->
        Logger.info("Vino not found")

        case Availibility.get_latest_beer_status_by_shop_id(@taphouse_id) do
          %{is_available: true} ->
            Availibility.create_beer_status!(%{
              beer_shop_id: @taphouse_id,
              username: "Pivotomated",
              is_available: false
            })

          _ ->
            Logger.info("Vino is not available - no need to update")
        end

      {:ok, vino} ->
        Logger.info("Vino found: #{inspect(vino)}")

        case Availibility.get_latest_beer_status_by_shop_id(@taphouse_id) do
          %{is_available: true} ->
            Logger.info("Vino is already available")

          _ ->
            Availibility.create_beer_status!(%{
              beer_shop_id: @taphouse_id,
              username: "Pivotomated",
              is_available: true,
              comment: "Tap ##{vino.number} - #{vino.size} for #{vino.price} kr."
            })
        end

      {:error, reason} ->
        # Log error
        Logger.error("Scraping failed: #{reason}")
        []
    end
  end

  defp schedule_next_scrape do
    # Schedule next scrape in 1 hour
    Process.send_after(self(), :scrape, 60 * 60 * 1000)
  end
end

# Supervisor to manage the GenServer
defmodule BeerScraperSupervisor do
  @moduledoc false
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      # WebScraper GenServer
      BeerScraper
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
