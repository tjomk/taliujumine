defmodule AppWeb.LocationView do
  use AppWeb, :view
  alias AppWeb.LocationView

  def render("index.json", %{locations: locations}) do
    %{data: render_many(locations, LocationView, "location.json")}
  end

  def render("show.json", %{location: location}) do
    %{data: render_one(location, LocationView, "location.json")}
  end

  def render("location.json", %{location: location}) do
    %{id: location.id,
      name: location.name,
      city: location.city,
      country: location.country,
      slug: location.slug,
      url: location.url,
      location: location.location,
      description: location.description}
  end
end
