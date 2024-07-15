module Frontend exposing (..)

import Array
import Browser exposing (UrlRequest(..))
import Effect.Browser.Events
import Effect.Browser.Navigation
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Http
import Effect.Lamdera
import Effect.Subscription as Subscription
import Effect.Task
import Effect.Time as Time
import Effect.WebGL as WebGL exposing (Entity, Mesh, Shader, XrRenderError(..))
import Geometry.Interop.LinearAlgebra.Point3d as Point3d
import Html
import Html.Events
import Json.Decode
import Lamdera
import Length
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Obj.Decode
import TriangularMesh
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
      , boundaryMesh = WebGL.triangleFan []
      , previousBoundary = Nothing
      , biplaneMesh = WebGL.triangleFan []
      }
    , Effect.Http.get
        { url = "/biplane.obj"
        , expect = Obj.Decode.expectObj GotBiplaneObj Length.meters Obj.Decode.triangles
        }
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
            ( model
            , WebGL.requestXrStart [ WebGL.clearColor 0.5 0.5 0.5 1, WebGL.depth 1 ] |> Effect.Task.attempt StartedXr
            )

        StartedXr result ->
            case result of
                Ok data ->
                    ( { model
                        | isInVr = True
                        , previousBoundary = data.boundary
                        , boundaryMesh = getBoundaryMesh data.boundary
                      }
                    , WebGL.renderXrFrame (entities model) |> Effect.Task.attempt RenderedXrFrame
                    )

                Err _ ->
                    ( model, Command.none )

        RenderedXrFrame result ->
            case result of
                Ok pose ->
                    ( { model
                        | time = pose.time
                        , previousBoundary = pose.boundary
                        , boundaryMesh =
                            if model.previousBoundary == pose.boundary then
                                model.boundaryMesh

                            else
                                getBoundaryMesh pose.boundary
                      }
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
            , if key == "Escape" then
                WebGL.endXrSession |> Effect.Task.perform (\() -> EndedXrSession)

              else
                Command.none
            )

        EndedXrSession ->
            ( model, Command.none )

        GotBiplaneObj result ->
            case result of
                Ok mesh2 ->
                    ( { model
                        | biplaneMesh =
                            WebGL.indexedTriangles
                                (TriangularMesh.vertices mesh2
                                    |> Array.toList
                                    |> List.map
                                        (\point ->
                                            { position = Point3d.toVec3 point
                                            , color = Vec3.vec3 1 1 0
                                            }
                                        )
                                )
                                (TriangularMesh.faceIndices mesh2)
                      }
                    , Command.none
                    )

                Err error ->
                    ( model, Command.none )


getBoundaryMesh : Maybe (List Vec3) -> Mesh Vertex
getBoundaryMesh maybeBoundary =
    case maybeBoundary of
        Just (first :: rest) ->
            let
                heightOffset =
                    Vec3.vec3 0 1 0

                length =
                    List.length rest + 1 |> toFloat
            in
            List.foldl
                (\v state ->
                    let
                        t =
                            state.index / length
                    in
                    { index = state.index + 1
                    , first = v
                    , quads =
                        { position = state.first, color = Vec3.vec3 t (1 - t) (0.5 + t / 2) }
                            :: { position = v, color = Vec3.vec3 t (1 - t) (0.5 + t / 2) }
                            :: { position = Vec3.add heightOffset v, color = Vec3.vec3 t (1 - t) (0.5 + t / 2) }
                            :: { position = Vec3.add heightOffset state.first, color = Vec3.vec3 t (1 - t) (0.5 + t / 2) }
                            :: state.quads
                    }
                )
                { index = 0, first = first, quads = [] }
                (rest ++ [ first ])
                |> .quads
                |> quadsToMesh

        _ ->
            WebGL.triangleFan []


quadsToMesh : List a -> WebGL.Mesh a
quadsToMesh vertices =
    WebGL.indexedTriangles
        vertices
        (getQuadIndicesHelper vertices 0 [])


getQuadIndicesHelper : List a -> Int -> List ( Int, Int, Int ) -> List ( Int, Int, Int )
getQuadIndicesHelper list indexOffset newList =
    case list of
        _ :: _ :: _ :: _ :: rest ->
            getQuadIndicesHelper
                rest
                (indexOffset + 1)
                (( 4 * indexOffset + 3, 4 * indexOffset + 1, 4 * indexOffset )
                    :: ( 4 * indexOffset + 2, 4 * indexOffset + 1, 4 * indexOffset + 3 )
                    :: newList
                )

        _ ->
            newList


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


entities : FrontendModel -> { time : Time.Posix, xrView : WebGL.XrView, inputs : List WebGL.XrInput } -> List Entity
entities model { time, xrView, inputs } =
    [ WebGL.entity
        vertexShader
        fragmentShader
        mesh
        { perspective = xrView.projectionMatrix
        , viewMatrix = xrView.viewMatrixInverse
        , modelTransform = Mat4.identity
        }
    , WebGL.entity
        vertexShader
        fragmentShader
        model.boundaryMesh
        { perspective = xrView.projectionMatrix
        , viewMatrix = xrView.viewMatrixInverse
        , modelTransform = Mat4.identity
        }
    ]
        ++ List.filterMap
            (\input ->
                case ( input.orientation, input.handedness ) of
                    ( Just orientation, WebGL.LeftHand ) ->
                        WebGL.entity
                            vertexShader
                            fragmentShader
                            model.biplaneMesh
                            { perspective = xrView.projectionMatrix
                            , viewMatrix = xrView.viewMatrixInverse
                            , modelTransform = Mat4.scale3 0.01 0.01 0.01 orientation.matrix
                            }
                            |> Just

                    _ ->
                        Nothing
            )
            inputs



-- Mesh


mesh : Mesh Vertex
mesh =
    let
        thickness =
            0.05
    in
    [ { position = vec3 1 0 -thickness, color = vec3 1 0 0 }
    , { position = vec3 1 0 thickness, color = vec3 1 0 0 }
    , { position = vec3 0 0 thickness, color = vec3 1 0 0 }
    , { position = vec3 0 0 -thickness, color = vec3 1 0 0 }
    , { position = vec3 -thickness 0 1, color = vec3 0 0 1 }
    , { position = vec3 thickness 0 1, color = vec3 0 0 1 }
    , { position = vec3 thickness 0 0, color = vec3 0 0 1 }
    , { position = vec3 -thickness 0 0, color = vec3 0 0 1 }
    ]
        |> quadsToMesh


handMesh =
    let
        thickness =
            0.05

        length =
            0.2
    in
    [ { position = vec3 length 0 -thickness, color = vec3 1 0 0 }
    , { position = vec3 length 0 thickness, color = vec3 1 0 0 }
    , { position = vec3 0 0 thickness, color = vec3 1 0 0 }
    , { position = vec3 0 0 -thickness, color = vec3 1 0 0 }
    , { position = vec3 -thickness 0 length, color = vec3 0 0 1 }
    , { position = vec3 thickness 0 length, color = vec3 0 0 1 }
    , { position = vec3 thickness 0 0, color = vec3 0 0 1 }
    , { position = vec3 -thickness 0 0, color = vec3 0 0 1 }
    , { position = vec3 0 length -thickness, color = vec3 0 1 0 }
    , { position = vec3 0 length thickness, color = vec3 0 1 0 }
    , { position = vec3 0 0 thickness, color = vec3 0 1 0 }
    , { position = vec3 0 0 -thickness, color = vec3 0 1 0 }
    ]
        |> quadsToMesh


type alias Uniforms =
    { perspective : Mat4, viewMatrix : Mat4, modelTransform : Mat4 }



-- Shaders


vertexShader : Shader Vertex Uniforms { vColor : Vec3 }
vertexShader =
    [glsl|
attribute vec3 position;
attribute vec3 color;

uniform mat4 modelTransform;
uniform mat4 viewMatrix;
uniform mat4 perspective;

varying vec3 vColor;

void main(void) {
    gl_Position = perspective * viewMatrix * modelTransform * vec4(position, 1.0);
    vColor = color;
}
    |]


fragmentShader : Shader {} a { vColor : Vec3 }
fragmentShader =
    [glsl|
precision mediump float;
varying vec3 vColor;

void main(void) {
    gl_FragColor = vec4(vColor, 1.0);
}
    |]
