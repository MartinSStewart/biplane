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
            ( model, WebGL.requestXrStart |> Effect.Task.attempt StartedXr )

        StartedXr result ->
            let
                _ =
                    Debug.log "StartedXr" result
            in
            case result of
                Ok _ ->
                    ( { model | isInVr = True }, WebGL.renderXrFrame |> Effect.Task.perform RenderedXrFrame )

                Err _ ->
                    ( model, Command.none )

        RenderedXrFrame _ ->
            ( model, WebGL.renderXrFrame |> Effect.Task.perform RenderedXrFrame )


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
        , WebGL.toHtmlWith
            [ WebGL.clearColor 1 1 0 1, WebGL.depth 1 ]
            [ Html.Attributes.width 1024
            , Html.Attributes.height 512
            , Html.Attributes.style "width" "1024px"
            , Html.Attributes.style "height" "512px"
            ]
            [ WebGL.entity
                vertexShader
                fragmentShader
                mesh
                { perspective = perspective (toFloat (Time.posixToMillis model.time) / 1000) }
            ]
        ]
    }


perspective : Float -> Mat4
perspective t =
    Mat4.mul
        (Mat4.makePerspective 45 1 0.01 100)
        (Mat4.makeLookAt (vec3 (4 * cos t) 0 (4 * sin t)) (vec3 0 0 0) (vec3 0 1 0))



-- Mesh


type alias Vertex =
    { position : Vec3
    , color : Vec3
    }


mesh : Mesh Vertex
mesh =
    WebGL.triangles
        [ ( Vertex (vec3 0 0 0) (vec3 1 0 0)
          , Vertex (vec3 1 1 0) (vec3 0 1 0)
          , Vertex (vec3 1 -1 0) (vec3 0 0 1)
          )
        ]



-- Shaders


type alias Uniforms =
    { perspective : Mat4 }


vertexShader : Shader Vertex Uniforms { vcolor : Vec3 }
vertexShader =
    [glsl|

        attribute vec3 position;
        attribute vec3 color;
        uniform mat4 perspective;
        varying vec3 vcolor;

        void main () {
            gl_Position = perspective * vec4(position, 1.0);
            vcolor = color;
        }

    |]


fragmentShader : Shader {} Uniforms { vcolor : Vec3 }
fragmentShader =
    [glsl|

        precision mediump float;
        varying vec3 vcolor;

        void main () {
            gl_FragColor = vec4(vcolor, 1.0);
        }

    |]
