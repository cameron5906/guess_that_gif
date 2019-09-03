module State exposing(..)
import Types exposing(..)
import Time exposing(..)
import Commands exposing(..)

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