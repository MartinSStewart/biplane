module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Effect.Browser.Events
import Effect.Browser.Navigation
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Lamdera
import Effect.Task
import Effect.Time as Time
import Effect.WebGL as WebGL exposing (Entity, Mesh, Shader)
import Html
import Html.Attributes
import Html.Events
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
        , subscriptions = \m -> Effect.Browser.Events.onAnimationFrame AnimationFrame
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
            case result of
                Ok pose ->
                    let
                        _ =
                            Debug.log "abc" ()
                    in
                    ( model, WebGL.renderXrFrame (entities model) |> Effect.Task.attempt RenderedXrFrame )

                Err _ ->
                    Debug.todo "RenderedXrFrame error"


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


entities : FrontendModel -> WebGL.XrView -> List Entity
entities model eyeView =
    [ WebGL.entityWith
        []
        vertexShader
        fragmentShader
        mesh
        { modelTransform = Mat4.makeRotate (toFloat (Time.posixToMillis model.time) / 1000) (Vec3.vec3 0 1 0) }
    ]



-- Mesh


type alias Vertex =
    { position : Vec3
    }


mesh : Mesh Vertex
mesh =
    WebGL.triangles
        [ ( Vertex (vec3 -0.04 -0.04 0.1)
          , Vertex (vec3 0.04 -0.04 0.1)
          , Vertex (vec3 0.04 0.04 0.1)
          )
        ]


type alias Uniforms =
    { modelTransform : Mat4 }



-- Shaders


vertexShader : Shader Vertex Uniforms {}
vertexShader =
    [glsl|
  attribute vec3 position;

  uniform mat4 modelTransform;

  void main(void) {
    gl_Position = modelTransform * vec4(position, 1.0);
  }
    |]


fragmentShader : Shader {} a {}
fragmentShader =
    [glsl|
  void main(void) {
    gl_FragColor = vec4(1.0, 0.5, 0.0, 1.0);
  }
    |]
