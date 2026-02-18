defmodule LargeHumour.Repo.Migrations.EditJokes2 do
  use Ecto.Migration

  def change do
    alter table(:jokes) do
      add :source_joke_id, :integer
      add :llm_meta, :map
    end

  end
end
