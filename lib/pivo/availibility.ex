defmodule Pivo.Availibility do
  @moduledoc """
  The Availibility context.
  """

  import Ecto.Query, warn: false
  alias Pivo.Repo

  alias Pivo.Availibility.BeerStatus

  def list_beer_shops do
    [
      %{
        id: "a4edf6d8-1fc7-49da-a687-65fc3d151069",
        name: "Kihoskh",
        logo: "kihoskh_logo.avif",
        website: "https://www.kihoskh.dk",
        lat: 55.66644759532798,
        lng: 12.55304832864403,
        vino: true,
        style: "Can"
      },
      %{
        id: "e65fc1d3-035d-4c62-9915-cd3a5fcf7196",
        name: "Rallys",
        logo: "rallys_logo.png",
        website: "https://www.rallys.dk",
        lat: 55.64846734279557,
        lng: 12.532315540117958,
        vino: true,
        style: "Can"
      },
      %{
        id: "afec5c50-637f-487d-a03f-e780ac1712c9",
        name: "Peders",
        logo: "peders_logo.png",
        lat: 55.6792037555745,
        lng: 12.569022168955275,
        vino: true,
        style: "Side pull"
      },
      %{
        id: "5b37fbb7-d03b-4536-b8dc-34ee9b3e7fc3",
        name: "Taphouse",
        logo: "taphouse_logo.png",
        lat: 55.67623174183128,
        lng: 12.571488122353864,
        vino: true,
        style: "Side pull"
      },
      %{
        id: "50e4ff87-9bd0-4b52-a897-bb0ca19a6943",
        name: "Mikkeller & Friends Bottle Shop",
        logo: "mikkeller_bottle_shop_logo.png",
        lat: 55.683796786548264,
        lng: 12.569227882377323,
        vino: false,
        style: "Can"
      }
    ]
  end

  def get_latest_beer_status_by_shop_id(shop_id) do
    from(bs in BeerStatus,
      where: bs.beer_shop_id == ^shop_id,
      order_by: [desc: bs.inserted_at],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Returns the list of beer_status.

  ## Examples

      iex> list_beer_status()
      [%BeerStatus{}, ...]

  """
  def list_beer_status do
    Repo.all(BeerStatus)
  end

  @doc """
  Creates a beer_status.

  ## Examples

      iex> create_beer_status(%{field: value})
      {:ok, %BeerStatus{}}

      iex> create_beer_status(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_beer_status(attrs \\ %{}) do
    %BeerStatus{}
    |> BeerStatus.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking beer_status changes.

  ## Examples

      iex> change_beer_status(beer_status)
      %Ecto.Changeset{data: %BeerStatus{}}

  """
  def change_beer_status(%BeerStatus{} = beer_status, attrs \\ %{}) do
    BeerStatus.changeset(beer_status, attrs)
  end
end
