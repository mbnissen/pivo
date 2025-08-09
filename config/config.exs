# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  pivo: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix_analytics,
  duckdb_path: System.get_env("DUCKDB_PATH") || "analytics.duckdb",
  app_domain: "whereisvino.dk",
  postgres_conn: "dbname=pivo_dev user=postgres password=postgres host=localhost",
  cache_ttl: 120,
  in_memory: true

config :pivo, BasicAuth, username: "admin", password: "secret"

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :pivo, Pivo.Mailer, adapter: Swoosh.Adapters.Local

# Configures the endpoint
config :pivo, PivoWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: PivoWeb.ErrorHTML, json: PivoWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Pivo.PubSub,
  live_view: [signing_salt: "o5dfbfxO"]

config :pivo,
  ecto_repos: [Pivo.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.7",
  pivo: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

config :timex, default_timezone: "Europe/Copenhagen"

import_config "#{config_env()}.exs"
