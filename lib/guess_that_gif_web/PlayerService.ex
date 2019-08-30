import Ecto.Query
alias GuessThatGif.Repo

defmodule GuessThatGif.PlayerService do
    def create(username) do
        if (username |> String.length) < 3 do
            {:error, "Username is too short"}
        else if (username |> String.length) > 16 do
            {:error, "Username is too long"}
        else
            insertion =
                Repo.insert %GuessThatGif.Player {
                    username: username,
                    total_correct_guesses: 0,
                    total_times_won: 0,
                    total_wrong_guesses: 0,
                    games_played: 0,
                    game: 0
                }

                case insertion do
                    {:ok, player} ->
                        {:success, player}
                    {:error, _changeset} ->
                        {:error, "Failed to create player entity"}
                end
            end
        end
    end

    def set_game_id(player_id, game_id) do
        player = GuessThatGif.Player |> (Repo.get player_id)

        player
            |> Ecto.Changeset.change(game: game_id)
            |> Repo.update
    end
end
