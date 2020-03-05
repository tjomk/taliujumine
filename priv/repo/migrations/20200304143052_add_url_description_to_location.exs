defmodule App.Repo.Migrations.AddUrlDescriptionToLocation do
  use Ecto.Migration

  def change do
    alter table("locations") do
      add :url, :string
      add :description, :string
      add :location, {:array, :float}
    end
  end
end
