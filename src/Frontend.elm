module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Effect.Browser.Events
import Effect.Browser.Navigation
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Lamdera
import Effect.Task
import Effect.Time as Time
import Effect.WebGL
import Html
import Html.Attributes
import Html.Events
import Json.Encode
import Lamdera
import Types exposing (..)
import Url


app =
    Effect.Lamdera.frontend
        Lamdera.sendToBackend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Effect.Browser.Events.onAnimationFrame AnimationFrame
        , view = view
        }


init : Url.Url -> Effect.Browser.Navigation.Key -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
init url key =
    ( { key = key
      , time = Time.millisToPosix 0
      }
    , Command.none
    )


update : FrontendMsg -> FrontendModel -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Effect.Browser.Navigation.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Effect.Browser.Navigation.load url
                    )

        UrlChanged url ->
            ( model, Command.none )

        NoOpFrontendMsg ->
            ( model, Command.none )

        AnimationFrame time ->
            ( { model | time = time }, Command.none )

        PressedEnterVr ->
            ( model, Effect.WebGL.requestXrStart |> Effect.Task.attempt StartedXr )

        StartedXr result ->
            let
                _ =
                    Debug.log "StartedXr" result
            in
            case result of
                Ok ok ->
                    ( model, Effect.WebGL.renderXrFrame |> Effect.Task.perform RenderedXrFrame )

                Err _ ->
                    ( model, Command.none )

        RenderedXrFrame _ ->
            ( model, Effect.WebGL.renderXrFrame |> Effect.Task.perform RenderedXrFrame )


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Command.none )


view : FrontendModel -> Browser.Document FrontendMsg
view model =
    { title = "Biplane!"
    , body =
        [ Html.button [ Html.Events.onClick PressedEnterVr ] [ Html.text "Enter VR" ]
        , Effect.WebGL.toHtmlWith
            [ Effect.WebGL.clearColor 1 1 0 1, Effect.WebGL.depth 1 ]
            [ Html.Attributes.width 1024
            , Html.Attributes.height 512
            , Html.Attributes.style "width" "1024px"
            , Html.Attributes.style "height" "512px"
            ]
            []
        ]
    }
