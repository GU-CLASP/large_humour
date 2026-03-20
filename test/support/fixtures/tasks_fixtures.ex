defmodule LargeHumour.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LargeHumour.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        joke_id: 42,
        rater_id: "some rater_id"
      })
      |> LargeHumour.Tasks.create_task()

    task
  end
end
