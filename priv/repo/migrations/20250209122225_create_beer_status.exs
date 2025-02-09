defmodule Pivo.Repo.Migrations.CreateBeerStatus do
  use Ecto.Migration

  def change do
    create table(:beer_status, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :username, :text
      add :is_available, :boolean, default: false, null: false
      add :beer_shop_id, :binary_id

      timestamps(type: :utc_datetime_usec)
    end
  end
end
