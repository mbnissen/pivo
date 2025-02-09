defmodule Pivo.Repo do
  use Ecto.Repo,
    otp_app: :pivo,
    adapter: Ecto.Adapters.Postgres
end
