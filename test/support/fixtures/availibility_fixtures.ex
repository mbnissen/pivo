defmodule Pivo.AvailibilityFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pivo.Availibility` context.
  """

  @doc """
  Generate a beer_status.
  """
  def beer_status_fixture(attrs \\ %{}) do
    {:ok, beer_status} =
      attrs
      |> Enum.into(%{
        beer_shop_id: "some beer_shop_id",
        is_available: true,
        username: "some username"
      })
      |> Pivo.Availibility.create_beer_status()

    beer_status
  end
end
