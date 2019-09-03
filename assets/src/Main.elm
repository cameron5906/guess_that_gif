module Main exposing (..)

import Browser
import Http exposing (..)
import Task exposing (..)
import Json.Decode as D
import Json.Encode as E
import Html exposing(..)

import Types exposing(..)
import Encoders exposing(..)
import Decoders exposing(..)
import View exposing(..)
import State exposing(..)
import Commands exposing(..)

main =
    Browser.element
        {
            init = \() -> initModel,
            update = update,
            view = view,
            subscriptions = subscriptions
        }

--Render out each piece of the page
view: Model -> Html Msg
view model =
    if model.session == "" then
        render_join_screen model
    else
        render_game_screen model