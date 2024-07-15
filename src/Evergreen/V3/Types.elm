module Evergreen.V3.Types exposing (..)

import Browser
import Effect.Browser.Navigation
import Effect.Time
import Effect.WebGL
import Url


type alias FrontendModel =
    { key : Effect.Browser.Navigation.Key
    , time : Effect.Time.Posix
    , isInVr : Bool
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
    | StartedXr (Result Effect.WebGL.XrStartError Int)
    | RenderedXrFrame (Result Effect.WebGL.XrRenderError Effect.WebGL.XrPose)


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
