defmodule LargeHumour.Repo.Migrations.CreateJokes do
  use Ecto.Migration

  def change do
    create table(:jokes) do
      add :seed, :boolean, default: false, null: false
      add :code, :string
      add :text, :text

      timestamps(type: :utc_datetime)
    end
  end
end
