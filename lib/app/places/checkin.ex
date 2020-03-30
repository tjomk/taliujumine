defmodule App.Places.Checkin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "checkins" do
    field :minutes, :float
    field :times, :integer, default: 1
    field :comment, :string, size: 512
    field :name, :string, size: 64
    belongs_to :location, App.Places.Location
    belongs_to :user, App.Users.User
    timestamps()
  end

  @doc false
  def changeset(checkin, attrs) do
    checkin
    |> cast(attrs, [:minutes, :times, :comment, :name, :user])
    |> validate_length(:comment, max: 512)
    |> validate_length(:name, max: 64)
    |> validate_required([:location])
  end
end
