defmodule AppWeb.CheckinView do
  use AppWeb, :view
  alias AppWeb.CheckinView

  def render("index.json", %{checkins: checkins}) do
    %{data: render_many(checkins, CheckinView, "checkin.json")}
  end

  def render("show.json", %{checkin: checkin}) do
    %{data: render_one(checkin, CheckinView, "checkin.json")}
  end

  def render("checkin.json", %{checkin: checkin}) do
    %{id: checkin.id,
      name: checkin.name}
  end
end
