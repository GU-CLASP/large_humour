defmodule LargeHumour.RatingsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LargeHumour.Ratings` context.
  """

  @doc """
  Generate a rating.
  """
  def rating_fixture(attrs \\ %{}) do
    {:ok, rating} =
      attrs
      |> Enum.into(%{
        joke_id: 42,
        rating: "some rating"
      })
      |> LargeHumour.Ratings.create_rating()

    rating
  end
end
