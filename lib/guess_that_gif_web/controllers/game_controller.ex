defmodule GuessThatGifWeb.GameController do
  use GuessThatGifWeb, :controller

  def start(conn, _params) do
    json(conn, %{herp_derp: True})
  end

  def join(conn, _params) do

  end

  def info(conn, _params) do

  end
end
