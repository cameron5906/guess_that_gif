module View exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as D

import Types exposing(..)

onKeyDown: (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (D.map tagger keyCode)

render_player_list: Model -> Html Msg
render_player_list {players} =
    div [class "player-list"][
        div [] (List.map render_player players) --loop through players list and call player render func
    ]

render_player: Player -> Html Msg
render_player {name, guess} =
    div [class "player"] [
        text name,
        if guess /= "" then 
            div [class "guess-bubble"][
                text (guess ++ "!"),
                div [class "triangle"][]
            ] 
        else 
            p[][]
    ]

render_status: Model -> Html Msg
render_status model =
    div [class "game-status"][
        text model.status
    ]

render_image: Model -> Html Msg
render_image {gif_url, seconds_remaining} =
    div [class "image-preview"][
        p [][
            if seconds_remaining > 0 then
                text ("You have " ++ String.fromInt seconds_remaining ++ " seconds time remaining")
            else if seconds_remaining < 0 then
                text ""
            else
                text "Time is up!"
        ],
        img[src gif_url][]
    ]

render_guess_input model =
    input [class "guess-input", placeholder "Type your guess here", onKeyDown GuessKeyDown, onInput GuessContentChanged, value model.guess_input][]

render_my_turn: Model -> Html Msg
render_my_turn model =
    div [class "my-turn"] [
        h1[] [text "It's your turn!"],
        h4[] [text "Enter a search phrase"],
        input[placeholder "Search Query to guess", onInput QueryInputChanged, value model.query_input][],
        button[onClick SendNewQuery][text "Submit"]
    ]

render_join_screen: Model -> Html Msg
render_join_screen model =
    div [class "join-screen"][
        h1[] [text "Guess That Gif"],
        h4[] [text model.join_status],
        if model.join_mode == "join" then input[placeholder "Game Code", onInput GameCodeInputChange][] else p[][],
        if model.join_mode /= "" then input[placeholder "Username", onInput UsernameInputChange][] else p[][],
        if model.join_mode /= "start" then button[onClick JoinGame][text "Join"] else p[][],
        if model.join_mode /= "join" then button[onClick CreateGame][text "Start a room"] else p[][],
        if model.join_mode /= "" then button[onClick BackToMenu][text "Go back"] else p[][]
    ]

render_game_screen model =
    div[] [
        render_player_list model,
        if model.gif_url == "" && not model.my_turn then 
            render_status model
        else 
            p[][],
        if model.gif_url /= ""  then
            render_image model 
        else 
            p[][],
        if model.my_turn && model.gif_url == "" then 
            render_my_turn model
        else
            p[][],
        render_guess_input model,
        p[class "join-code"][text ("Share code " ++ model.game_code ++ " with your friends")]
    ]