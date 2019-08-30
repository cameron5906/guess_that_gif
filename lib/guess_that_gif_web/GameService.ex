import Ecto.Query

defmodule GuessThatGif.GameService do
    @type game_create_result :: {successful :: atom, code :: String.t}

    def get_game(game_code) do
        status = get_game_status game_code

        result =
            GuessThatGif.Repo.one(
                from g in "game",
                where: g.join_code == ^game_code,
                select: %{
                    id: g.id,
                    join_code: g.join_code,
                    is_active: g.is_active,
                    gif_url: g.gif_url,
                    gif_timeout: g.gif_timeout,
                    status: ^status
                }
            )

        players =
            GuessThatGif.Repo.all(
                from ply in "player",
                where: ply.game == ^result.id,
                select: %{
                    name: ply.username,
                    guess: "",
                    guess_time: 0
                }
            )

        if result != nil do
            %{
                info: result,
                players: players
            }
        else
            %{error: "Game does not exist"}
        end
    end

    def create_game(owner_id) do
        game_code = GuessThatGif.StringGenerator.generate 4

        insertion =
            %GuessThatGif.Game{
                creator_id: owner_id,
                join_code: game_code,
                is_active: true,
                gif_url: "",
                gif_timeout: 0,
                status: "Waiting for players"
            } |> GuessThatGif.Repo.insert

        case insertion do
            {:ok, game} ->
                {:ok, game_code, game.id}
            {:error, _changeset} ->
                {:error, ""}
        end
    end

    def get_game_status(game_code) do
        has_enough_players = have_enough_players game_code

        if has_enough_players do
            ""
        else
            "Waiting for players"
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

    def have_enough_players(game_code) do
        current_players = 
            (from p in GuessThatGif.Player,
                join: g in GuessThatGif.Game,
                on: g.id == p.game,
                where: g.join_code == ^game_code,
                select: count(p.id)) 
                |> GuessThatGif.Repo.one

        current_players >1
    end

    def is_guess_correct(game_code, guess) do
        current_query =
            (from q in GuessThatGif.SearchQuery,
            where: q.game_code == ^game_code)
            |> first

        current_query.query == guess
    end

    def get_next_player_turn(game_code) do
        
    end

    def broadcast_message(game_code, message) do
        GuessThatGif.Repo.one(
            from g in GuessThatGif.Game,
            where: g.join_code == ^game_code,
            select: g
        )
            |> Ecto.Changeset.change(status: message)
            |> GuessThatGif.Repo.update
    end
end
