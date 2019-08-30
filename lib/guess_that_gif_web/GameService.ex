import Ecto.Query

defmodule GuessThatGif.GameService do
    @type game_create_result :: {successful :: atom, code :: String.t}

    def get_game(game_code) do
        result =
            GuessThatGif.Repo.one(
                from g in "game",
                where: g.join_code == ^game_code,
                select: %{
                    join_code: g.join_code,
                    is_active: g.is_active,
                    gif_url: g.gif_url,
                    gif_timeout: g.gif_timeout
                }
            )

        if result != nil do
            result
        else
            %{error: "Game does not exist"}
        end
    end

    def create_game(owner_id) do
        game_code = Integer.to_string DateTime.to_unix DateTime.utc_now

        insertion =
            %GuessThatGif.Game{
                creator_id: owner_id,
                join_code: game_code,
                is_active: true
            } |> GuessThatGif.Repo.insert

        case insertion do
            {:ok, _} ->
                {:ok, game_code}
            {:error, _changeset} ->
                {:error, ""}
        end
    end

    def set_current_gif(game_code, new_url) do
        GuessThatGif.Repo.one(
            from g in GuessThatGif.Game,
            where: g.join_code == ^game_code,
            select: g
        )
            |> Ecto.Changeset.change(
                    gif_url: new_url,
                    gif_timeout: (DateTime.to_unix DateTime.utc_now) + 20
                )
            |> GuessThatGif.Repo.update

        true
    end
end
