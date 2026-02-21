defmodule LargeHumour.PromptsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LargeHumour.Prompts` context.
  """

  @doc """
  Generate a prompt.
  """
  def prompt_fixture(attrs \\ %{}) do
    {:ok, prompt} =
      attrs
      |> Enum.into(%{
        body: "some body",
        title: "some title"
      })
      |> LargeHumour.Prompts.create_prompt()

    prompt
  end
end
