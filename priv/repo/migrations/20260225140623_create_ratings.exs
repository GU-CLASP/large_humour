defmodule LargeHumour.Repo.Migrations.CreateRatings do
  use Ecto.Migration

  def change do
    create table(:ratings) do
      add :joke_id, :integer
      add :rating, :string

      timestamps(type: :utc_datetime)
    end
  end
end
