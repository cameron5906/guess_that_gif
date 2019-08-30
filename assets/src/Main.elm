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
        session: String,
        my_turn: Bool,
        join_mode: String,
        join_status: String,
        game_code: String,
        username: String,
        guess_input: String,
        players: List Player,
        gif_url: String,
        gif_timeout: Int,
        seconds_remaining: Int,
        current_time: Int,
        status: String
    }

type alias GameInfo =
    {
        gif_url: String,
        gif_timeout: Int,
        status: String
    }

type alias ServerGameState =
    {
        info: GameInfo,
        players: List Player
    }

type alias CreateGameResponseData =
    {
        created: Bool,
        code: Maybe String,
        error: Maybe String,
        session: Maybe String
    }

type alias JoinGameResponseData =
    {
        session: Maybe String,
        error: Maybe String
    }

type alias SendGuessResponseData =
    {
        correct: Bool
    }

type Msg
    = GuessKeyDown Int
    | UpdateTimeRemaining Time.Posix
    | UpdateCurrentTime Posix
    | RemoveNewGuesses Posix
    | GuessContentChanged String
    | UpdateGameStateFromServer (Result Http.Error ServerGameState)
    | RetrieveGameStateFromServer Posix
    | NewQueryResponse (Result Http.Error Bool)
    | JoinGame
    | CreateGame
    | UsernameInputChange String
    | CreateGameResponse (Result Http.Error CreateGameResponseData)
    | BackToMenu
    | JoinGameResponse (Result Http.Error JoinGameResponseData)
    | GameCodeInputChange String
    | SendGuessResponse (Result Http.Error SendGuessResponseData)

--Create the initial state of the game
initModel: (Model, Cmd Msg)
initModel =
    ({
        session = "",
        my_turn = False,
        join_mode = "",
        join_status = "Please select an option below to play",
        game_code = "",
        username = "",
        guess_input = "",
        players = [],
        gif_url = "",
        gif_timeout = 0,
        status = "",
        seconds_remaining = 10,
        current_time = 0
    }, Cmd.none)

--JSON DECODERS
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

--JSON ENCODERS
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

---UPDATE FUNCTIONS
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

---STATE UPDATE
update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        UsernameInputChange text ->
            ({model | username = text}, Cmd.none)
        JoinGame ->
            if model.join_mode == "" then
                ({model | join_mode = "join", join_status = "Enter a room code and username"}, Cmd.none)
            else
                (model, join_game_request model.username model.game_code)
        CreateGame ->
            if model.join_mode == "" then
                ({model | join_mode = "start", join_status = "Enter a username to start"}, Cmd.none)
            else
                (model, create_game_request model.username)
        GuessKeyDown keycode ->
            if keycode == 13 then
                if model.my_turn then
                    (model, Cmd.none)
                else
                    ({model | guess_input = ""}, send_guess model)
            else
                (model, Cmd.none)
        UpdateTimeRemaining time ->
            let
                currentTimeUTC = (Time.posixToMillis time) // 1000
            in
                ({model | seconds_remaining = model.gif_timeout - currentTimeUTC}, Cmd.none)
        UpdateCurrentTime time ->
            let
                currentTimeUTC = (Time.posixToMillis time) // 1000
            in
                ({model | current_time = currentTimeUTC}, Cmd.none)
        RemoveNewGuesses time ->
            (update_remove_latest_guesses model, Cmd.none)
        GuessContentChanged txt ->
            ({model | guess_input = txt}, Cmd.none)
        RetrieveGameStateFromServer time ->
            if model.game_code == "" then
                (model, Cmd.none)
            else
                (model, update_state_from_server model)
        UpdateGameStateFromServer result ->
            case result of
                Ok data ->
                    (update_remove_latest_guesses {
                        model | 
                        gif_url = data.info.gif_url,
                        gif_timeout = data.info.gif_timeout,
                        status = data.info.status,
                        players = data.players
                    }, Cmd.none)
                Err _ ->
                    (model, Cmd.none)
        NewQueryResponse success ->
            (model, Cmd.none)
        CreateGameResponse result ->
            case result of
                Ok data ->
                    if data.created then
                        ({
                            model |
                            game_code = Maybe.withDefault "" data.code,
                            session = Maybe.withDefault "" data.session
                        }, Cmd.none)
                    else
                        ({
                            model |
                            join_status = Maybe.withDefault "" data.error
                        }, Cmd.none)
                Err _ ->
                    (model, Cmd.none)
        BackToMenu ->
            ({model | join_mode = "", join_status = "Please select an option below to play"}, Cmd.none)
        JoinGameResponse result ->
            case result of
                Ok data ->
                    ({
                        model |
                        session = Maybe.withDefault "" data.session
                    }, Cmd.none)
                Err _ ->
                    (model, Cmd.none)
        GameCodeInputChange code ->
            ({
                model |
                game_code = code
            }, Cmd.none)
        SendGuessResponse result ->
            case result of
                Ok data ->
                    (model, Cmd.none)
                Err _ ->
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
            else
                text "Time is up!"
        ],
        img[src gif_url][]
    ]

render_guess_input model =
    input [class "guess-input", placeholder "Type your guess here", onKeyDown GuessKeyDown, onInput GuessContentChanged, value model.guess_input][]

render_my_turn: Html Msg
render_my_turn =
    div [class "my-turn"] [
        h1[] [text "It's your turn!"],
        h4[] [text "Enter a search phrase"],
        input[placeholder "Search Query to guess"][]
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
        if model.my_turn == True then 
            render_my_turn 
        else
            p[][],
        render_guess_input model,
        p[class "join-code"][text ("Share code " ++ model.game_code ++ " with your friends")]
    ]
--Render out each piece of the page
view: Model -> Html Msg
view model =
    if model.session == "" then
        render_join_screen model
    else
        render_game_screen model