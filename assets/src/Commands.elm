module Commands exposing (..)
import Types exposing(..)
import Http exposing(..)
import Decoders exposing(..)
import Encoders exposing(..)

update_remove_latest_guesses: Model -> Model
update_remove_latest_guesses model =
    {
        model |
        players = List.map(
        \ply -> 
            if model.current_time - ply.guess_time > 2 then
                {ply | guess = ""}
            else
                ply
        ) model.players
    }

update_player_guess: Model -> String -> String -> Model
update_player_guess model username guess =
    {
        model |
        players = 
            List.map(
                \ply ->
                    if ply.name == username then
                        {ply | guess = guess, guess_time = model.current_time}
                    else
                        ply
            ) model.players
    }

create_game_request: String -> Cmd Msg
create_game_request username =
    Http.post
        {
            url = "/game/start",
            body = Http.jsonBody <| create_game_request_encoder username,
            expect = Http.expectJson CreateGameResponse create_game_response_decoder
        }

join_game_request: String -> String -> Cmd Msg
join_game_request username code =
    Http.post
        {
            url = "/game/join",
            body = Http.jsonBody <| join_game_request_encoder username code,
            expect = Http.expectJson JoinGameResponse join_game_response_decoder
        }

update_state_from_server: Model -> Cmd Msg
update_state_from_server model =
    Http.get
        {
            url = "/game/info?id=" ++ model.game_code ++ "&session=" ++ model.session,
            expect = Http.expectJson UpdateGameStateFromServer gamestate_decoder
        }

send_new_query: Model -> String -> Cmd Msg
send_new_query model text =
    Http.post
        {
            url = "/game/query?id=" ++ model.game_code,
            body = Http.jsonBody <| query_request_encoder text,
            expect = Http.expectJson NewQueryResponse new_query_response_decoder
        }

send_guess: Model -> Cmd Msg
send_guess model =
    Http.post
        {
            url = "/game/guess",
            body = Http.jsonBody <| send_guess_request_encoder model.session model.guess_input,
            expect = Http.expectJson SendGuessResponse send_guess_response_decoder
        }