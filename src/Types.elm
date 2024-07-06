module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Effect.Browser.Navigation
import Effect.Time as Time
import Effect.WebGL
import Url exposing (Url)


type alias FrontendModel =
    { key : Effect.Browser.Navigation.Key
    , time : Time.Posix
    , isInVr : Bool
    }


type alias BackendModel =
    { message : String
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | AnimationFrame Time.Posix
    | PressedEnterVr
    | StartedXr (Result Effect.WebGL.XrStartError Int)
    | RenderedXrFrame Int


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
