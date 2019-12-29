defmodule App.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :city, :string, size: 64
    field :country, :string, size: 64
    field :name, :string, size: 64
    has_many :weather, App.Weather
    has_many :checkins, App.Checkin

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :city, :country])
    |> validate_required([:name, :city, :country])
    |> validate_length(:city, min: 2)
    |> validate_length(:country, min: 4)
  end
end
