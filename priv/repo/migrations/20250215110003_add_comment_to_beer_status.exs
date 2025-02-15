defmodule Pivo.Repo.Migrations.AddCommentToBeerStatus do
  use Ecto.Migration

  def change do
    alter table(:beer_status) do
      add :comment, :text
    end
  end
end
