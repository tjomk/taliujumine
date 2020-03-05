defmodule App.Repo.Migrations.AddSlugToLocation do
  use Ecto.Migration

  def change do
    alter table("locations") do
      add :slug, :string
    end
  end
end
