module Evergreen.V1.Types exposing (..)

import Browser
import Effect.Browser.Navigation
import Effect.Time
import Url


type alias FrontendModel =
    { key : Effect.Browser.Navigation.Key
    , time : Effect.Time.Posix
    }


type alias BackendModel =
    { message : String
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | AnimationFrame Effect.Time.Posix
    | PressedEnterVr


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
