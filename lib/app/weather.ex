defmodule App.Weather do
  use Ecto.Schema
  import Ecto.Changeset

  schema "weather" do
    field :air, :float
    field :created_date, :utc_datetime
    field :water, :float
    belongs_to :location, App.Location
    timestamps()
  end

  @doc false
  def changeset(weather, attrs) do
    weather
    |> cast(attrs, [:created_date, :air, :water])
    |> validate_required([:created_date, :air, :water])
  end
end
