defmodule LargeHumour.Ratings.Rating do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ratings" do
    field :joke_id, :integer
    field :rating, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(rating, attrs) do
    rating
    |> cast(attrs, [:joke_id, :rating])
    |> validate_required([:joke_id, :rating])
    |> validate_format(:rating, ~r/^[0-6][yz]?$/)
  end
end
