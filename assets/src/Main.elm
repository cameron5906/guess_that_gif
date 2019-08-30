module Main exposing (..)

import Browser
import Http exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time exposing (..)
import Task exposing (..)
import Json.Decode as D
import Json.Encode as E

main =
    Browser.element
        {
            init = \() -> initModel,
            update = update,
            view = view,
            subscriptions = subscriptions
        }

----TYPE DEFINITIONS
type alias Player =
    {
        name: String,
        guess: String,
        guess_time: Int
    }

type alias Model =
    {
        game_code: String,
        username: String,
        guess_input: String,
        players: List Player,
        gif_url: String,
        gif_timeout: Int,
        seconds_remaining: Int,
        current_time: Int
    }

type alias ServerGameState =
    {
        gif_url: String,
        gif_timeout: Int
    }

type Msg
    = AddPlayer
    | RemovePlayer
    | GuessKeyDown Int
    | UpdateTimeRemaining Time.Posix
    | UpdateCurrentTime Posix
    | RemoveNewGuesses Posix
    | GuessContentChanged String
    | UpdateGameStateFromServer (Result Http.Error ServerGameState)
    | RetrieveGameStateFromServer Posix
    | NewQueryResponse (Result Http.Error Bool)

--Create the initial state of the game
initModel: (Model, Cmd Msg)
initModel =
    ({
        game_code = "1567121751",
        username = "",
        guess_input = "",
        players = [
            {
                name = "Cameron",
                guess = "",
                guess_time = 0
            },
            {
                name = "Josh",
                guess = "Cat",
                guess_time = 0
            }
        ],
        gif_url = "https://media.giphy.com/media/SOmjomEnNHsrK/giphy.gif",
        gif_timeout = 0,
        seconds_remaining = 10,
        current_time = 0
    }, Cmd.none)

--JSON DECODERS
gamestate_decoder: D.Decoder ServerGameState
gamestate_decoder =
    D.map2 ServerGameState
        (D.field "gif_url" D.string)
        (D.field "gif_timeout" D.int)

new_query_response_decoder: D.Decoder Bool
new_query_response_decoder =
    D.field "success" D.bool

--JSON ENCODERS
query_request_encoder: String -> E.Value
query_request_encoder query =
    E.object [ ("query", E.string query)]

---UPDATE FUNCTIONS
update_remove_latest_guesses: Model -> Model
update_remove_latest_guesses model =
    {
        model |
        players = List.map(
        \ply -> 
            if model.current_time - ply.guess_time > 1500 then
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

update_state_from_server: Model -> Cmd Msg
update_state_from_server model =
    Http.get
        {
            url = "/game/info?id=" ++ model.game_code,
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

---STATE UPDATE
update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        AddPlayer ->
            (model, Cmd.none)
        RemovePlayer ->
            (model, Cmd.none)
        GuessKeyDown keycode ->
            if keycode == 13 then
                let
                    updatedModel = update_player_guess model model.username model.guess_input --TODO: replace model.username with the player's username who guessed  
                in
                    ({updatedModel| guess_input = ""}, send_new_query model model.guess_input)
            else
                (model, Cmd.none)
        UpdateTimeRemaining time ->
            let
                currentTimeUTC = (Time.posixToMillis time) // 1000
            in
                ({model | seconds_remaining = model.gif_timeout - currentTimeUTC}, Cmd.none)
        UpdateCurrentTime time ->
            ({model | current_time = Time.posixToMillis time}, Cmd.none)
        RemoveNewGuesses time ->
            (update_remove_latest_guesses model, Cmd.none)
        GuessContentChanged txt ->
            ({model | guess_input = txt}, Cmd.none)
        RetrieveGameStateFromServer time ->
            (model, update_state_from_server model)
        UpdateGameStateFromServer result ->
            case result of
                Ok data ->
                    ({
                        model | 
                        gif_url = data.gif_url,
                        gif_timeout = data.gif_timeout
                    }, Cmd.none)
                Err _ ->
                    (model, Cmd.none)
        NewQueryResponse success ->
            (model, Cmd.none)

--SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch([
        Time.every 1000 UpdateTimeRemaining,
        Time.every 250 UpdateCurrentTime,
        Time.every 250 RemoveNewGuesses,
        Time.every 1000 RetrieveGameStateFromServer
    ])

onKeyDown: (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (D.map tagger keyCode)

---RENDERING PIECES
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

render_status =
    div [class "game-status"][
        text "Status"
    ]

render_image: Model -> Html Msg
render_image {gif_url, seconds_remaining} =
    div [class "image-preview"][
        p [][
            if seconds_remaining > 0 then
                text ("You have " ++ String.fromInt seconds_remaining ++ " seconds time remaining")
            else
                text "Time is up!"
        ],
        img[src gif_url][]
    ]

render_guess_input model =
    input [class "guess-input", placeholder "Type your guess here", onKeyDown GuessKeyDown, onInput GuessContentChanged, value model.guess_input][]

render_join_screen: Html Msg
render_join_screen =
    div [class "join-screen"][
        h1[] [text "Guess That Gif"],
        h4[] [text "Please enter a game code and username"],
        input[placeholder "Game Code"][],
        input[placeholder "Username"][],
        button[][text "Join"],
        button[][text "Start a room"]
    ]

render_game_screen model =
    div[] [
        render_player_list model,
        if model.gif_url == "" then render_status else p[][],
        if model.gif_url /= "" then render_image model else p[][],
        render_guess_input model
    ]
--Render out each piece of the page
view: Model -> Html Msg
view model =
    if model.username == "" then
        render_join_screen
    else
        render_game_screen model