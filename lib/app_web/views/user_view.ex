defmodule AppWeb.UserView do
  use AppWeb, :view
  alias AppWeb.UserView

  def render("index.json", %{user: user}) do
    %{data: render_many(user, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.email,
      fullName: user.full_name,
      username: user.username}
  end
end
