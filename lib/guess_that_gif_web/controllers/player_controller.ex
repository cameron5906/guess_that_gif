defmodule GuessThatGifWeb.PlayerController do
  use GuessThatGifWeb, :controller

  def register(conn, _params) do
    render(conn, "index.html")
  end

  def login(conn, _params) do

  end

  def info(conn, _params) do

  end
end
