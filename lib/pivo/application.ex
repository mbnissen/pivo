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

    # Start the beer scraper without linking
    {:ok, _pid} = Pivo.BeerScraper.start()

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
