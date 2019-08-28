import Ecto.Query

defmodule GuessThatGif.PlayerService do
    def validate_password_errors(password) do
        if String.length(password) < 4 or String.length(password) > 32 do
            {false, "Password must be between 4 and 32 characters in length"}
        else
            {true, ""}
        end
    end

    def validate_username_errors(username) do
        if GuessThatGif.Player |> GuessThatGif.Repo.exists?(username: username) do
            {false, "Username is taken"}
        else
            {true, ""}
        end
    end

    def create(username, password) do
        {username_result, username_error} = validate_username_errors username
        {password_result, password_error} = validate_password_errors password

        if username_result === false do
            {:error, username_error}
        else if password_result === false do
            {:error, password_error}
        else
            insertion =
                GuessThatGif.Repo.insert! %GuessThatGif.Player
                {
                    username: username,
                    password: password,
                    total_correct_guesses: 0,
                    total_times_won: 0,
                    total_wrong_guesses: 0,
                    games_played: 0
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
end