defmodule LargeHumour.Repo.Migrations.CreatePrompts do
  use Ecto.Migration

  def change do
    create table(:prompts) do
      add :title, :string
      add :body, :text

      timestamps(type: :utc_datetime)
    end
  end
end
