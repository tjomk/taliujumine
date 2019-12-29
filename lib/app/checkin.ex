defmodule App.Checkin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "checkins" do
    field :minutes, :float
    belongs_to :location, App.Location
    belongs_to :user, App.User
    timestamps()
  end

  @doc false
  def changeset(checkin, attrs) do
    checkin
    |> cast(attrs, [:minutes])
    |> validate_required([:minutes])
  end
end
