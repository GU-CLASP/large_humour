defmodule LargeHumour.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :rater_id, :string
      add :joke_id, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
