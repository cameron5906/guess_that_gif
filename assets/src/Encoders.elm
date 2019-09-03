module Encoders exposing (..)

import Json.Encode as E

query_request_encoder: String -> E.Value
query_request_encoder query =
    E.object [ ("query", E.string query)]

create_game_request_encoder: String -> E.Value
create_game_request_encoder username =
    E.object [ ("username", E.string username)]

join_game_request_encoder: String -> String -> E.Value
join_game_request_encoder username code =
    E.object [ 
                ("username", E.string username), 
                ("code", E.string code)
            ]

send_guess_request_encoder: String -> String -> E.Value
send_guess_request_encoder session guess =
    E.object [
        ("session", E.string session),
        ("guess", E.string guess)
    ]