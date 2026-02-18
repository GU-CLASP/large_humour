defmodule LargeHumour.Jokes.Joke do
  use Ecto.Schema
  import Ecto.Changeset

  schema "jokes" do
    field :seed, :boolean, default: false
    field :code, :string
    field :text, :string
    field :source_joke_id, :integer
    field :llm_meta, :map

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(joke, attrs) do
    joke
    |> cast(attrs, [:seed, :code, :text, :source_joke_id, :llm_meta])
    |> validate_required([:seed, :code, :text])
  end
end
