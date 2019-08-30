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
  end

  scope "/game", GuessThatGifWeb do
    pipe_through :api

    post "/start", GameController, :start
    post "/join", GameController, :join
    get "/info", GameController, :info
    post "/query", GameController, :query
    post "/guess", GameController, :guess
  end

  # Other scopes may use custom stacks.
  # scope "/api", GuessThatGifWeb do
  #   pipe_through :api
  # end
end
