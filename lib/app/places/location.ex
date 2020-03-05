defmodule App.Places.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :city, :string, size: 64
    field :country, :string, size: 64
    field :name, :string, size: 64
    field :slug, :string, size: 64
    field :url, :string, size: 64
    field :description, :string, size: 256
    field :location, {:array, :float}
    has_many :weather, App.Weather
    has_many :checkins, App.Places.Checkin

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :city, :country, :url, :description])
    |> validate_required([:name, :city, :country])
    |> validate_length(:city, min: 2)
    |> validate_length(:country, min: 4)
    |> validate_length(:url, max: 64)
    |> validate_length(:description, max: 256)
  end
end
