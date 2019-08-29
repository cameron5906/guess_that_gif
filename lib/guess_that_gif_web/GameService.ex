defmodule GuessThatGif.GameService do
    @type game_create_result :: {successful :: atom, code :: String.t}


    @spec create_game(player :: struct) :: game_create_result
    def create_game(%{"id" => player_id}) do
        game_code = Integer.to_string DateTime.to_unix DateTime.utc_now

        insertion = 
            %GuessThatGif.Game{
                creator_id: player_id,
                join_code: game_code,
                is_active: true
            } |> GuessThatGif.Repo.insert

        case insertion do
            {:ok, _} ->
                {:success, game_code}
            {:error, _changeset} ->
                {:error, ""}
        end
    end
end