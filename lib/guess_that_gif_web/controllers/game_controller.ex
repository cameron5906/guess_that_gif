defmodule GuessThatGifWeb.GameController do
  use GuessThatGifWeb, :controller

  def start(conn, _params) do
    result = GuessThatGif.GameService.create_game %{id: 1}
    conn
      |> json(%{
        created:
          case result do 
            {:success, _code} -> 
              true
            _ -> 
              false
          end,
        code: result.code
      })
  end

  def join(conn, _params) do
    conn
      |> json(%{
        test: true
      })
  end

  def info(conn, _params) do
    conn
      |> json(%{
        test: true
      })
  end

  def guess(conn, %{"guess" => guess}) do
    conn 
      |> json(%{
        guess: guess
        })
  end
end
