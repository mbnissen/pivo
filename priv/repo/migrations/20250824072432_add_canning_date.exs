defmodule Pivo.Repo.Migrations.AddCanningDate do
  use Ecto.Migration

  def change do
    alter table(:beer_status) do
      add :canning_date, :string
    end
  end
end
