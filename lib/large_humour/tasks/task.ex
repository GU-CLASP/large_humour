defmodule LargeHumour.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :rater_id, :string
    field :joke_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:rater_id, :joke_id])
    |> validate_required([:rater_id, :joke_id])
  end
end
