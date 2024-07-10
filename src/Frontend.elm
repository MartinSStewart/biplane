module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Effect.Browser.Events
import Effect.Browser.Navigation
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Lamdera
import Effect.Subscription as Subscription
import Effect.Task
import Effect.Time as Time
import Effect.WebGL as WebGL exposing (Entity, Mesh, Shader, XrRenderError(..))
import Html
import Html.Attributes
import Html.Events
import Json.Decode
import Json.Encode
import Lamdera
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
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
        , subscriptions =
            \m ->
                Subscription.batch
                    [ Effect.Browser.Events.onAnimationFrame AnimationFrame
                    , Effect.Browser.Events.onKeyDown (Json.Decode.map KeyDown (Json.Decode.field "key" Json.Decode.string))
                    ]
        , view = view
        }


init : Url.Url -> Effect.Browser.Navigation.Key -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
init url key =
    ( { key = key
      , time = Time.millisToPosix 0
      , isInVr = False
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
            let
                _ =
                    Debug.log "AnimationFrame" ()
            in
            ( { model | time = time }, Command.none )

        PressedEnterVr ->
            ( model, WebGL.requestXrStart [ WebGL.clearColor 0.5 0.5 0.5 1 ] |> Effect.Task.attempt StartedXr )

        StartedXr result ->
            case result of
                Ok _ ->
                    ( { model | isInVr = True }
                    , WebGL.renderXrFrame (entities model) |> Effect.Task.attempt RenderedXrFrame
                    )

                Err _ ->
                    ( model, Command.none )

        RenderedXrFrame result ->
            case Debug.log "RenderedXrFrame" result of
                Ok pose ->
                    ( { model | time = pose.time }
                    , WebGL.renderXrFrame (entities model) |> Effect.Task.attempt RenderedXrFrame
                    )

                Err XrSessionNotStarted ->
                    ( { model | isInVr = False }, Command.none )

                Err XrLostTracking ->
                    ( model
                    , WebGL.renderXrFrame (entities model) |> Effect.Task.attempt RenderedXrFrame
                    )

        KeyDown key ->
            ( model
            , if Debug.log "key" key == "Escape" then
                WebGL.endXrSession |> Effect.Task.perform (\() -> EndedXrSession)

              else
                Command.none
            )

        EndedXrSession ->
            ( model, Command.none )


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Command.none )


view : FrontendModel -> Browser.Document FrontendMsg
view model =
    { title = "Biplane!"
    , body =
        [ if model.isInVr then
            Html.text "Currently in VR"

          else
            Html.text "Not in VR"
        , Html.button [ Html.Events.onClick PressedEnterVr ] [ Html.text "Enter VR" ]
        ]
    }


entities : FrontendModel -> { time : Time.Posix, xrView : WebGL.XrView } -> List Entity
entities model { time, xrView } =
    [ WebGL.entityWith
        []
        vertexShader
        fragmentShader
        mesh
        { perspective = xrView.projectionMatrix
        , viewMatrix = xrView.viewMatrixInverse
        , modelTransform = Mat4.identity --Mat4.makeRotate (toFloat (Time.posixToMillis time) / 1000) (Vec3.vec3 0 1 0)
        }
    ]



-- Mesh


type alias Vertex =
    { position : Vec3
    }


mesh : Mesh Vertex
mesh =
    WebGL.triangles
        [ ( Vertex (vec3 -0.4 -0.4 -2)
          , Vertex (vec3 0.4 -0.4 -2)
          , Vertex (vec3 0.4 0.4 -2)
          )
        ]


type alias Uniforms =
    { perspective : Mat4, viewMatrix : Mat4, modelTransform : Mat4 }



-- Shaders


vertexShader : Shader Vertex Uniforms {}
vertexShader =
    [glsl|
  attribute vec3 position;

  uniform mat4 modelTransform;
  uniform mat4 viewMatrix;
  uniform mat4 perspective;

  void main(void) {
    gl_Position = perspective * viewMatrix * modelTransform * vec4(position, 1.0);
  }
    |]


fragmentShader : Shader {} a {}
fragmentShader =
    [glsl|
  void main(void) {
    gl_FragColor = vec4(1.0, 0.5, 0.0, 1.0);
  }
    |]
