defmodule App.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name, :string
      add :city, :string
      add :country, :string
      timestamps()
    end

  end
end
