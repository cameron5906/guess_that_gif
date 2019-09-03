module Decoders exposing (..)
import Types exposing(..)
import Json.Decode as D

create_game_response_decoder: D.Decoder CreateGameResponseData
create_game_response_decoder =
    D.map4 CreateGameResponseData
        (D.field "created" D.bool)
        (D.maybe (D.field "code" D.string))
        (D.maybe (D.field "error" D.string))
        (D.maybe (D.field "session" D.string))

join_game_response_decoder: D.Decoder JoinGameResponseData
join_game_response_decoder =
    D.map2 JoinGameResponseData
        (D.maybe (D.field "session" D.string))
        (D.maybe (D.field "error" D.string))

gamestate_info_decoder: D.Decoder GameInfo
gamestate_info_decoder =
    D.map3 GameInfo
        (D.field "gif_url" D.string)
        (D.field "gif_timeout" D.int)
        (D.field "status" D.string)

gamestate_player_decoder: D.Decoder Player
gamestate_player_decoder =
    D.map3 Player
        (D.field "name" D.string)
        (D.field "guess" D.string)
        (D.field "guess_time" D.int)

gamestate_decoder: D.Decoder ServerGameState
gamestate_decoder =
    D.map2 ServerGameState
        (D.field "info" gamestate_info_decoder)
        (D.field "players" (D.list gamestate_player_decoder))

new_query_response_decoder: D.Decoder Bool
new_query_response_decoder =
    D.field "success" D.bool

send_guess_response_decoder: D.Decoder SendGuessResponseData
send_guess_response_decoder =
    D.map SendGuessResponseData
        (D.field "correct" D.bool)