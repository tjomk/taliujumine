defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", AppWeb do
    pipe_through :api

    resources "/users", UserController
    resources "/checkins", CheckinController
    resources "/locations", LocationController
  end

  scope "/", AppWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/*page", PageController, :index
  end

end
