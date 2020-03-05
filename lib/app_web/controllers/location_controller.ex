defmodule AppWeb.LocationController do
  use AppWeb, :controller

  alias App.Places
  alias App.Places.Location

  action_fallback AppWeb.FallbackController

  def index(conn, _params) do
    locations = Places.list_locations()
    render(conn, "index.json", locations: locations)
  end

  def create(conn, %{"location" => location_params}) do
    with {:ok, %Location{} = location} <- Places.create_location(location_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.location_path(conn, :show, location))
      |> render("show.json", location: location)
    end
  end

  def show(conn, %{"id" => id}) do
    location = Places.get_location_by_slug!(id)
    render(conn, "show.json", location: location)
  end

  def update(conn, %{"id" => id, "location" => location_params}) do
    location = Places.get_location!(id)

    with {:ok, %Location{} = location} <- Places.update_location(location, location_params) do
      render(conn, "show.json", location: location)
    end
  end

  def delete(conn, %{"id" => id}) do
    location = Places.get_location!(id)

    with {:ok, %Location{}} <- Places.delete_location(location) do
      send_resp(conn, :no_content, "")
    end
  end
end
