defmodule GuessThatGifWeb.Router do
  use GuessThatGifWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GuessThatGifWeb do
    pipe_through :browser

    get "/", PageController, :index
    post "/player/register", PlayerController, :register
    post "/player/login", PlayerController, :login
    post "/game/start", GameController, :start
    post "/game/join", GameController, :join
    get "/game/info", GameController, :info
  end

  # Other scopes may use custom stacks.
  # scope "/api", GuessThatGifWeb do
  #   pipe_through :api
  # end
end
