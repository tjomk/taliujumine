defmodule App.Repo.Migrations.CreateWeather do
  use Ecto.Migration

  def change do
    create table(:weather) do
      add :created_date, :utc_datetime
      add :air, :float
      add :water, :float
      add :location_id, references(:locations)
      timestamps()
    end

  end
end
