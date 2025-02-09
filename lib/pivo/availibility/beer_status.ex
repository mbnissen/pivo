defmodule Pivo.Availibility.BeerStatus do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "beer_status" do
    field :username, :string
    field :is_available, :boolean, default: false
    field :beer_shop_id, :binary_id

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(beer_status, attrs) do
    beer_status
    |> cast(attrs, [:username, :is_available, :beer_shop_id])
    |> validate_required([:is_available, :beer_shop_id])
  end
end
