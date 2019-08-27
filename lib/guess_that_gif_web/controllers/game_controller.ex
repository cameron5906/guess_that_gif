defmodule GuessThatGifWeb.GameController do
  use GuessThatGifWeb, :controller

  def start(conn, _params) do
    json(conn, %{fuck_me: True})
  end

  def join(conn, _params) do

  end

  def info(conn, _params) do

  end
end
