defmodule Pivo.Availibility do
  @moduledoc """
  The Availibility context.
  """

  import Ecto.Query, warn: false

  alias Pivo.Availibility.BeerStatus
  alias Pivo.Repo

  def list_beer_shops do
    [
      %{
        id: "a4edf6d8-1fc7-49da-a687-65fc3d151069",
        name: "Kihoskh",
        logo: "kihoskh_logo.avif",
        website: "https://www.kihoskh.dk",
        lat: 55.66644759532798,
        lng: 12.55304832864403,
        style: "Can"
      },
      %{
        id: "e65fc1d3-035d-4c62-9915-cd3a5fcf7196",
        name: "Rallys",
        logo: "rallys_logo.png",
        website: "https://www.rallys.dk",
        lat: 55.64846734279557,
        lng: 12.532315540117958,
        style: "Can"
      },
      %{
        id: "afec5c50-637f-487d-a03f-e780ac1712c9",
        name: "Peders",
        logo: "peders_logo.png",
        lat: 55.67906605956423,
        lng: 12.569047498969876,
        style: "Side pull"
      },
      %{
        id: "5b37fbb7-d03b-4536-b8dc-34ee9b3e7fc3",
        name: "Taphouse",
        logo: "taphouse_logo.png",
        lat: 55.676187023783946,
        lng: 12.57152462344214,
        style: "Side pull"
      },
      %{
        id: "50e4ff87-9bd0-4b52-a897-bb0ca19a6943",
        name: "Mikkeller & Friends Bottle Shop",
        logo: "mikkeller_bottle_shop_logo.png",
        lat: 55.683796786548264,
        lng: 12.569227882377323,
        style: "Can"
      },
      %{
        id: "b04c2089-237e-4bb3-af74-792a5a42149b",
        name: "Væskebalancen",
        logo: "vaeskebalancen_logo.png",
        lat: 55.68649145580039,
        lng: 12.558541993254456,
        style: "Can"
      },
      %{
        id: "13a153e5-f435-4d2f-a819-d3a36e0417b5",
        name: "Bar' Godt",
        logo: "bar_godt_logo.jpeg",
        lat: 55.68002590186607,
        lng: 12.5752204,
        style: "Can"
      },
      %{
        id: "7d27d9bb-7a8c-4862-bee6-49eeb4d4a4e0",
        name: "Godt Øl",
        logo: "godt_oel_logo.png",
        lat: 55.676777201726246,
        lng: 12.57611779325444,
        style: "Can"
      },
      %{
        id: "47769859-e46e-4251-ba2e-8c75c3deaf97",
        name: "Tap 21 Craft Beer",
        logo: "tap_21_logo.jpg",
        lat: 55.678297274206976,
        lng: 12.54701247420993,
        style: "Can"
      },
      %{
        id: "b9f9376d-fe7b-4865-a131-bf286c8f915c",
        name: "Vinspecialisten Toft Vin",
        logo: "toft_vin_logo.jpg",
        lat: 55.66664572063112,
        lng: 12.576797797804993,
        style: "Can"
      },
      %{
        id: "0b6336ed-8b27-4133-8f31-f13a633b1be7",
        name: "Windsor Fisk & Skaldyr",
        logo: "windsor_logo.jpg",
        lat: 55.67855292094813,
        lng: 12.505014797790816,
        style: "Can"
      }
    ]
  end

  def get_latest_beer_status_by_shop_id(shop_id) do
    Repo.one(
      from(bs in BeerStatus,
        where: bs.beer_shop_id == ^shop_id,
        order_by: [desc: bs.inserted_at],
        limit: 1
      )
    )
  end

  @doc """
  Returns the list of beer_status.

  ## Examples

      iex> list_beer_status()
      [%BeerStatus{}, ...]

  """
  def list_beer_status do
    Repo.all(from(u in BeerStatus, order_by: [desc: u.inserted_at], limit: 100))
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

  def create_beer_status!(attrs \\ %{}) do
    %BeerStatus{}
    |> BeerStatus.changeset(attrs)
    |> Repo.insert!()
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

  def update_beer_status(beer_shop_id, nil, nil) do
    latest_status = get_latest_beer_status_by_shop_id(beer_shop_id)

    if latest_status.is_available || (!latest_status.is_available && latest_status.comment) do
      create_new_unavailable_status(beer_shop_id, nil)
    else
      :ok
    end
  end

  def update_beer_status(beer_shop_id, %{number: nil}, nil) do
    comment = "Available in cans"

    case get_latest_beer_status_by_shop_id(beer_shop_id) do
      %BeerStatus{is_available: true} ->
        :ok

      _ ->
        create_new_available_status(beer_shop_id, comment)
    end
  end

  def update_beer_status(beer_shop_id, vino, nil) do
    comment = "Tap ##{vino.number}"

    case get_latest_beer_status_by_shop_id(beer_shop_id) do
      %BeerStatus{is_available: true} ->
        :ok

      _ ->
        create_new_available_status(beer_shop_id, comment)
    end
  end

  def update_beer_status(beer_shop_id, nil, replacement) do
    comment = "Replaced by #{replacement.name} - #{replacement.brewery}"
    latest_status = get_latest_beer_status_by_shop_id(beer_shop_id)

    cond do
      is_nil(latest_status) || latest_status.is_available ->
        create_new_unavailable_status(beer_shop_id, comment)

      !latest_status.is_available && latest_status.comment != comment ->
        create_new_unavailable_status(beer_shop_id, comment)

      # Default case
      true ->
        :ok
    end
  end

  def update_beer_status(beer_shop_id, _vino, replacement) do
    comment = "Replaced by #{replacement.name} - #{replacement.brewery}, but available in cans"

    case get_latest_beer_status_by_shop_id(beer_shop_id) do
      %BeerStatus{is_available: true} ->
        :ok

      _ ->
        create_new_available_status(beer_shop_id, comment)
    end
  end

  defp create_new_available_status(beer_shop_id, comment) do
    create_beer_status!(%{
      beer_shop_id: beer_shop_id,
      username: "Pivotomated",
      comment: comment,
      is_available: true
    })
  end

  defp create_new_unavailable_status(beer_shop_id, comment) do
    create_beer_status!(%{
      beer_shop_id: beer_shop_id,
      username: "Pivotomated",
      comment: comment,
      is_available: false
    })
  end
end
