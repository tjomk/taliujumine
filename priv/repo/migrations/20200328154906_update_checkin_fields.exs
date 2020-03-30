defmodule App.Repo.Migrations.UpdateCheckinFields do
  use Ecto.Migration

  def change do
    alter table("checkins") do
      add :times, :integer, default: 1
      add :comment, :string
      add :name, :string
    end
  end
end
