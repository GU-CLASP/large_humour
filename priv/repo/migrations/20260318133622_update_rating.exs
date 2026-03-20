defmodule LargeHumour.Repo.Migrations.UpdateRating do
  use Ecto.Migration

  def change do
    execute("""
    ALTER TABLE ratings
    ALTER COLUMN rating TYPE integer
    USING rating::integer
    """)

    alter table(:ratings) do
      add :rater_id, :string
      add :weird_aspects, :string
      add :offensive, :boolean
      add :failed, :boolean
    end
  end
end
