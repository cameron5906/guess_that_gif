defmodule GuessThatGifWeb.GameController do
  use GuessThatGifWeb, :controller

  def start(conn, %{"username" => username}) do
    create_player_result = GuessThatGif.PlayerService.create username

    case create_player_result do
      {:success, player} ->
        result = GuessThatGif.GameService.create_game player.id

        conn
          |> json(
              case result do
                {:ok, code, game_id} ->
                  GuessThatGif.PlayerService.set_game_id player.id, game_id
                  %{
                    created: true, 
                    code: code,
                    session: player.session
                  }
                _ ->
                  %{created: false}
              end
            )
      {:error, message} ->
        conn
          |> json(%{
              created: false,
              error: message
            })
    end
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
