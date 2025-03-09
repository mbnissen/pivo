defmodule Pivo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :logger.add_handler(:my_sentry_handler, Sentry.LoggerHandler, %{
      config: %{metadata: [:file, :line]}
    })

    children = [
      PivoWeb.Telemetry,
      Pivo.Repo,
      {DNSCluster, query: Application.get_env(:pivo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Pivo.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Pivo.Finch},
      # Start a worker by calling: Pivo.Worker.start_link(arg)
      # Start to serve requests, typically the last entry
      PivoWeb.Endpoint
    ]

    # Start the beer scrapers without linking
    {:ok, _pid} = Pivo.BeerScraper.start()

    {:ok, _pid} =
      Pivo.UntappdBeerScraper.start(
        name: "Peders",
        beer_shop_id: "afec5c50-637f-487d-a03f-e780ac1712c9",
        vino_tap_number: "30",
        url: "https://untappd.com/v/peders/5696141",
        can_url: "https://untappd.com/v/peders/5696141?menu_id=95260"
      )

    {:ok, _pid} =
      Pivo.UntappdBeerScraper.start(
        name: "Bar Godt",
        beer_shop_id: "13a153e5-f435-4d2f-a819-d3a36e0417b5",
        url: "https://untappd.com/v/bar-godt/12187591"
      )

    {:ok, _pid} =
      Pivo.UntappdBeerScraper.start(
        name: "Godt Øl",
        beer_shop_id: "7d27d9bb-7a8c-4862-bee6-49eeb4d4a4e0",
        url: "https://untappd.com/v/godt-ol/7324555"
      )

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pivo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PivoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
