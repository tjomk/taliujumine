defmodule App.Repo.Migrations.CreateCheckins do
  use Ecto.Migration

  def change do
    create table(:checkins) do
      add :minutes, :float
      add :location_id, references(:locations)
      add :user_id, references(:users)
      timestamps()
    end

  end
end
