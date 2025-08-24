defmodule Pivo.Availibility.BeerStatus do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "beer_status" do
    field :username, :string
    field :is_available, :boolean, default: false
    field :beer_shop_id, :binary_id
    field :canning_date, :string
    field :comment, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(beer_status, attrs) do
    beer_status
    |> cast(attrs, [:username, :is_available, :beer_shop_id, :comment, :canning_date])
    |> validate_required([:is_available, :beer_shop_id])
    |> validate_length(:username, min: 3, max: 20)
    |> validate_format(:username, ~r/^[a-zA-Z0-9_]+$/, message: "must only contain letters, numbers, and underscores")
    |> validate_format(:comment, ~r/^(?!.*<[^>]+>).*$/, message: "comment cannot contain HTML tags")
    |> validate_format(:comment, ~r/^(?!.*<script).*$/, message: "comment cannot contain <script> tags")
    |> validate_format(:comment, ~r/^(?!.*javascript:).*$/, message: "comment cannot contain JavaScript injection")
    |> validate_format(:comment, ~r/^(?!.*on\w+=).*$/,
      message: "comment cannot contain JavaScript event handlers (e.g. onclick, onload)"
    )
  end
end
