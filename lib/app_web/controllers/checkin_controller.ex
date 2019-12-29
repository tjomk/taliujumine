defmodule AppWeb.CheckinController do
  use AppWeb, :controller

  alias App.Places
  alias App.Places.Checkin

  action_fallback AppWeb.FallbackController

  def index(conn, _params) do
    checkins = Places.list_checkins()
    render(conn, "index.json", checkins: checkins)
  end

  def create(conn, %{"checkin" => checkin_params}) do
    with {:ok, %Checkin{} = checkin} <- Places.create_checkin(checkin_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.checkin_path(conn, :show, checkin))
      |> render("show.json", checkin: checkin)
    end
  end

  def show(conn, %{"id" => id}) do
    checkin = Places.get_checkin!(id)
    render(conn, "show.json", checkin: checkin)
  end

  def update(conn, %{"id" => id, "checkin" => checkin_params}) do
    checkin = Places.get_checkin!(id)

    with {:ok, %Checkin{} = checkin} <- Places.update_checkin(checkin, checkin_params) do
      render(conn, "show.json", checkin: checkin)
    end
  end

  def delete(conn, %{"id" => id}) do
    checkin = Places.get_checkin!(id)

    with {:ok, %Checkin{}} <- Places.delete_checkin(checkin) do
      send_resp(conn, :no_content, "")
    end
  end
end
