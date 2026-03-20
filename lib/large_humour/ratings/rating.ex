defmodule LargeHumour.Ratings.Rating do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ratings" do
    field :joke_id, :integer
    field :rating, :integer
    field :rater_id, :string
    field :weird_aspects, :string
    field :offensive, :boolean
    field :failed, :boolean

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(rating, attrs) do
    rating
    |> cast(attrs, [:joke_id, :rating, :rater_id, :weird_aspects, :offensive, :failed])
    |> validate_required([:joke_id, :rating, :rater_id, :offensive, :failed])
  end
end
