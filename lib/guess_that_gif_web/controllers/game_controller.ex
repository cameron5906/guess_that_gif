defmodule GuessThatGifWeb.GameController do
  use GuessThatGifWeb, :controller

  def start(conn, _params) do
    result = GuessThatGif.GameService.create_game 1

    conn
      |> json(
          case result do
            {:ok, code} ->
              %{created: true, code: code}
            _ ->
              %{created: false}
          end
        )
  end

  def join(conn, _params) do
    conn
      |> json(%{
        test: true
      })
  end

  def info(conn, %{"id" => game_code}) do
    game_info =
      GuessThatGif.GameService.get_game game_code

    conn |> json(game_info)
  end

  def guess(conn, %{"guess" => guess}) do
    conn
      |> json(%{
        guess: guess
        })
  end

  def query(conn, %{"id" => game_code, "query" => query}) do
    url =
      (HTTPotion.get "https://api.tenor.com/v1/search?q=#{query}&key=VXG9MTYL5A08&limit=1").body
      |> Poison.decode!
      |> GuessThatGif.TenorService.get_url

    GuessThatGif.GameService.set_current_gif game_code, url

    conn
      |> json(%{
        url: url
      })
  end
end
