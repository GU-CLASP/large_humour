defmodule LargeHumour.JokesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LargeHumour.Jokes` context.
  """

  @doc """
  Generate a joke.
  """
  def joke_fixture(attrs \\ %{}) do
    {:ok, joke} =
      attrs
      |> Enum.into(%{
        code: "some code",
        seed: true,
        text: "some text"
      })
      |> LargeHumour.Jokes.create_joke()

    joke
  end
end
