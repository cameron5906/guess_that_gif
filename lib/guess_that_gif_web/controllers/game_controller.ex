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

  def join(conn, %{"username" => username, "code" => code}) do
    create_player_result = GuessThatGif.PlayerService.create username

    case create_player_result do
      {:success, player} ->
        result = GuessThatGif.GameService.can_join_game player.id, code

        case result do
          {:ok, game_id} ->
            GuessThatGif.PlayerService.set_game_id player.id, game_id
            conn |> json(%{
              session: player.session
            })
        end
      {:error, message} ->
        conn |> json(%{
          error: message
        })
    end
  end

  def info(conn, %{"session" => session, "id" => game_code}) do
    game_info =
      GuessThatGif.GameService.get_game game_code, session

    conn |> json(game_info)
  end

  def guess(conn, %{"session" => session, "guess" => guess}) do
    GuessThatGif.GameService.submit_guess session, guess

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
