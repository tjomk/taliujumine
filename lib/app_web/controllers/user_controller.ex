defmodule AppWeb.UserController do
  use AppWeb, :controller

  alias App.Users
  alias App.Users.User

  action_fallback AppWeb.FallbackController

  @doc """
  Returns the list of users. The following query parameters are supported:

  - q - free text search in first name, last name, or username fields
  """
  def index(conn, _params = %{"q" => search_query}) do
    users = Users.search_users(search_query)
    render(conn, "index.json", user: users)
  end

  @doc """
  Returns the list of users
  """
  def index(conn, _params) do
    users = Users.list_users()
    render(conn, "index.json", user: users)
  end


  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Users.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    with {:ok, %User{}} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
