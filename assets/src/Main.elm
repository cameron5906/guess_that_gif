module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

main =
    Browser.sandbox
        {
            init = initModel,
            update = update,
            view = view
        }

----TYPE DEFINITIONS
type alias Player =
    {
        name: String
    }

type alias Model =
    {
        players: List Player,
        gif_link: String
    }

type Msg
    = AddPlayer
    | RemovePlayer

--Create the initial state of the game
initModel: Model
initModel =
    {
        players = [
            {
                name = "Cameron"
            },
            {
                name = "Josh"
            }
        ],
        gif_link = ""
    }


---STATE UPDATE
update: Msg -> Model -> Model
update msg model =
    case msg of
        AddPlayer ->
            model
        RemovePlayer ->
            model

---RENDERING PIECES
render_player_list: Model -> Html Msg
render_player_list {players} =
    div [class "player-list"][
        div [] (List.map render_player players) --loop through players list and call player render func
    ]

render_player: {name: String} -> Html Msg
render_player {name} =
    div [class "player"] [text name]

render_status =
    div [class "game-status"][
        text "Status"
    ]

render_image =
    div [class "image-preview"][
        text "GIF Preview"
    ]

render_guess_input =
    input [class "guess-input"][

    ]

--Render out each piece of the page
view: Model -> Html Msg
view model =
    div [][
        render_player_list model,
        if model.gif_link == "" then render_status else p[][],
        if model.gif_link /= "" then render_image else p[][],
        render_guess_input
    ]