defmodule App.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :full_name, :string
      add :email, :string
      add :username, :string
      add :is_staff, :boolean, default: false, null: false
      add :password, :string
      timestamps()
    end

  end
end
