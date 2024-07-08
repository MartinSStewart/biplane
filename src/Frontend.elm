module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Effect.Browser.Events
import Effect.Browser.Navigation
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Lamdera
import Effect.Task
import Effect.Time as Time
import Effect.WebGL as WebGL exposing (Mesh, Shader)
import Html
import Html.Attributes
import Html.Events
import Json.Encode
import Lamdera
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 exposing (Vec3, vec3)
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
                    , WebGL.renderXrFrame (entities model) |> Effect.Task.perform RenderedXrFrame
                    )

                Err _ ->
                    ( model, Command.none )

        RenderedXrFrame _ ->
            ( model, WebGL.renderXrFrame (entities model) |> Effect.Task.perform RenderedXrFrame )


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


entities model =
    [ WebGL.entityWith
        []
        vertexShader
        fragmentShader
        mesh
        {}
    ]



-- Mesh


type alias Vertex =
    { aVertexPosition : Vec3
    }


mesh : Mesh Vertex
mesh =
    WebGL.triangles
        [ ( Vertex (vec3 -0.04 -0.04 0.1)
          , Vertex (vec3 0.04 -0.04 0.1)
          , Vertex (vec3 0.04 0.04 0.1)
          )
        ]



-- Shaders


vertexShader : Shader Vertex {} {}
vertexShader =
    [glsl|
  attribute vec3 aVertexPosition;

  void main(void) {
    gl_Position = vec4(aVertexPosition, 1.0);
  }
    |]


fragmentShader : Shader {} {} {}
fragmentShader =
    [glsl|
  void main(void) {
    gl_FragColor = vec4(1.0, 0.5, 0.0, 1.0);
  }
    |]
