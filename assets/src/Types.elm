module Types exposing (..)
import Http exposing(..)
import Time exposing (..)

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