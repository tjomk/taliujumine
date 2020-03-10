defmodule App.Places.Checkin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "checkins" do
    field :minutes, :float
    belongs_to :location, App.Places.Location
    belongs_to :user, App.Users.User
    timestamps()
  end

  @doc false
  def changeset(checkin, attrs) do
    checkin
    |> cast(attrs, [:minutes])
    |> validate_required([:minutes, :location, :user])
  end
end
