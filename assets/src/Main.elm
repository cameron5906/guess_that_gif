module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time exposing (..)
import Task exposing (..)
import Json.Decode as Json

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
        username: String,
        guess_input: String,
        players: List Player,
        gif_link: String,
        seconds_remaining: Int,
        current_time: Int
    }

type Msg
    = AddPlayer
    | RemovePlayer
    | GuessKeyDown Int
    | UpdateTimeRemaining Time.Posix
    | UpdateCurrentTime Posix
    | RemoveNewGuesses Posix
    | GuessContentChanged String

--Create the initial state of the game
initModel: (Model, Cmd Msg)
initModel =
    ({
        username = "Cameron",
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
        gif_link = "https://media.giphy.com/media/SOmjomEnNHsrK/giphy.gif",
        seconds_remaining = 10,
        current_time = 0
    }, Cmd.none)

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
                    ({updatedModel| guess_input = ""}, Cmd.none)
            else
                (model, Cmd.none)
        UpdateTimeRemaining time ->
            ({model | seconds_remaining = model.seconds_remaining - 1}, Cmd.none)
        UpdateCurrentTime time ->
            ({model | current_time = Time.posixToMillis time}, Cmd.none)
        RemoveNewGuesses time ->
            (update_remove_latest_guesses model, Cmd.none)
        GuessContentChanged txt ->
            ({model | guess_input = txt}, Cmd.none)

--SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch([
        Time.every 1000 UpdateTimeRemaining,
        Time.every 250 UpdateCurrentTime,
        Time.every 250 RemoveNewGuesses
    ])

onKeyDown: (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Json.map tagger keyCode)

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
render_image {gif_link, seconds_remaining} =
    div [class "image-preview"][
        p [][
            if seconds_remaining > 0 then
                text ("You have " ++ String.fromInt seconds_remaining ++ " seconds time remaining")
            else
                text "Time is up!"
        ],
        img[src gif_link][]
    ]

render_guess_input model =
    input [class "guess-input", placeholder "Type your guess here", onKeyDown GuessKeyDown, onInput GuessContentChanged, value model.guess_input][]

--Render out each piece of the page
view: Model -> Html Msg
view model =
    div [][
        render_player_list model,
        if model.gif_link == "" then render_status else p[][],
        if model.gif_link /= "" then render_image model else p[][],
        render_guess_input model
    ]