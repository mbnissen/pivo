# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this app does

Pivo (deployed at whereisvino.dk) is a Phoenix LiveView app that tracks the availability of a specific beer ("Vinohradská 11") at beer shops/taphouses in Copenhagen. The map at `/` shows shops and whether the beer is currently on tap or in cans.

## Common commands

- `mix setup` — install deps, create DB, run migrations, seed, install/build assets
- `mix phx.server` (or `iex -S mix phx.server`) — start the app on `localhost:4000`
- `mix test` — runs `ecto.create --quiet && ecto.migrate --quiet && test`
- `mix test test/path/to/file_test.exs:LINE` — run a single test
- `mix ecto.reset` — drop, recreate, migrate, seed
- `mix format` — formatter uses Phoenix.LiveView.HTMLFormatter and Styler plugins
- `mix deps.audit` — security audit (mix_audit)
- `mix assets.build` / `mix assets.deploy` — esbuild + tailwind v4 build (config in `config/config.exs`)

Tool versions are pinned in `.tool-versions` (Elixir 1.18.4-otp-27, Erlang 27.2.2, Node 22.13.1).

## Architecture

### Scraper supervision quirk
`lib/pivo/application.ex` starts beer scrapers via `GenServer.start` (not `start_link`) **outside** the supervision tree, then explicitly hardcodes shop entries with their UUIDs. Two scraper modules exist:

- `Pivo.BeerScraper` (`lib/pivo/taphouse_beer_scraper.ex`) — scrapes taphouse.dk HTML directly. Single instance, hardcoded `@taphouse_id`.
- `Pivo.UntappdBeerScraper` (`lib/pivo/untappd_beer_scraper.ex`) — one instance per shop registered by `name`. Scrapes Untappd menu pages.

Both poll on a 5-minute interval (`Process.send_after`). Adding a new shop = adding a new `Pivo.UntappdBeerScraper.start(...)` call in `application.ex` AND adding the shop's metadata (lat/lng/logo/style) to the hardcoded list in `Pivo.Availibility.list_beer_shops/0`. Shop UUIDs in `application.ex` MUST match the ones in `list_beer_shops/0`.

### Availability state machine
`Pivo.Availibility.update_beer_status/3` (note spelling: "Availibility" throughout the codebase) is dispatched on `(beer_shop_id, vino, replacement)` shape. It only inserts a new `BeerStatus` row when the latest status would actually change — e.g. it skips writes when the most recent row already reflects the current state. Status rows are append-only; "current" means the most recent `inserted_at` for a given `beer_shop_id`. Automated entries use `username: "Pivotomated"`.

### Untappd scraping logic
`Pivo.Scrapers.Untappd.get_vino_status/3` arity dispatches on which lookups apply to a given shop:
- `(url, nil, nil)` — just check tap list for "Vinohradská 11"
- `(url, vino_tap_number, nil)` — also identify what's replacing it on a known tap
- `(url, vino_tap_number, can_url)` — additionally check a separate cans menu URL

### Frontend / map
`PivoWeb.MapLive` renders a Mapbox map; the `MapHook` JS hook in `assets/js/hooks/map-hook.js` reads `data-access-token` and `data-locations` (JSON-encoded list from `Availibility.list_beer_shops/0` enriched with latest status). Mapbox token comes from `Application.get_env(:pivo, :mapbox)[:access_token]` (set in `config/runtime.exs`).

### Routing
`/` MapLive, `/about`, `/beer_status` + `/beer_status/new` (LiveView CRUD-ish for manual reports). `/admin/analytics` is gated by `PivoWeb.Plugs.BasicAuth` and exposes the `phoenix_analytics` dashboard. `/dev/dashboard` and `/dev/mailbox` are dev-only behind `:dev_routes`.

### Deployment
Fly.io (`fly.toml`, `Dockerfile`, `.github/workflows/fly-deploy.yml`). `phoenix_analytics` uses DuckDB (`DUCKDB_PATH` env var, defaults to `analytics.duckdb`).
