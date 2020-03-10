defmodule AppWeb.CheckinView do
  use AppWeb, :view
  alias AppWeb.CheckinView
  alias AppWeb.UserView

  def render("index.json", %{checkins: checkins}) do
    %{data: render_many(checkins, CheckinView, "checkin.json")}
  end

  def render("show.json", %{checkin: checkin}) do
    %{data: render_one(checkin, CheckinView, "checkin.json")}
  end

  def render("checkin.json", %{checkin: checkin}) do
    %{id: checkin.id,
      created: checkin.inserted_at,
      user: render_one(checkin.user, UserView, "user.json")}
  end
end
