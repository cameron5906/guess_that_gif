import Ecto.Query

defmodule GuessThatGifWeb.PlayerController do
  use GuessThatGifWeb, :controller

  def register(
    conn,
    %{
      "username" => username,
      "password" => password
  }) do
    if GuessThatGif.Player |> GuessThatGif.Repo.exists?(first_name: username) do
      conn |> json(%{error: "Username already exists"})
    else
      new_player =
        GuessThatGif.Repo.insert!(
          %GuessThatGif.Player
          {
            username: username,
            password: password,
            total_correct_guesses: 0,
            total_times_won: 0,
            total_wrong_guesses: 0,
            games_played: 0,

          }
        )

      conn |> json(%{id: new_player.id})
    end
  end

  def login(conn, _params) do

  end

  def info(conn, _params) do
    player = GuessThatGif.Player |> Ecto.Query.first

    conn |> json player
  end
end
