module Frontend exposing (app)

import Angle
import Array
import Browser exposing (UrlRequest(..))
import Direction3d
import Duration
import Effect.Browser.Events
import Effect.Browser.Navigation
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Http
import Effect.Lamdera
import Effect.Subscription as Subscription
import Effect.Task
import Effect.Time as Time
import Effect.WebGL as WebGL exposing (Entity, Mesh, Shader, XrRenderError(..))
import Effect.WebGL.Settings exposing (Setting)
import Geometry.Interop.LinearAlgebra.Direction3d as Direction3d
import Geometry.Interop.LinearAlgebra.Point3d as Point3d
import Geometry.Interop.LinearAlgebra.Vector3d as Vector3d
import Html
import Html.Attributes
import Html.Events
import Json.Decode
import Lamdera
import Length exposing (Meters)
import List.Extra
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (Vec3)
import Obj.Decode
import Point3d
import SketchPlane3d
import TriangularMesh
import Types exposing (..)
import Url
import Vector3d exposing (Vector3d)
import WebGL.Settings.Blend as Blend
import WebGL.Settings.DepthTest as DepthTest


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
      , startTime = Time.millisToPosix 0
      , isInVr = False
      , boundaryMesh = WebGL.triangleFan []
      , previousBoundary = Nothing
      , biplaneMesh = WebGL.triangleFan []
      }
    , Command.batch
        [ Effect.Http.get
            { url = "/biplane.obj"
            , expect = Obj.Decode.expectObj GotBiplaneObj Length.meters Obj.Decode.faces
            }
        , Time.now |> Effect.Task.perform GotStartTime
        ]
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
                    , Command.batch
                        [ WebGL.renderXrFrame (entities model) |> Effect.Task.attempt RenderedXrFrame
                        , if
                            List.any
                                (\input ->
                                    case List.Extra.getAt 0 input.buttons of
                                        Just button ->
                                            button.value > 0.5

                                        Nothing ->
                                            False
                                )
                                pose.inputs
                          then
                            WebGL.endXrSession |> Effect.Task.perform (\() -> TriggeredEndXrSession)

                          else
                            Command.none
                        ]
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
                                            { position = Point3d.toVec3 point.position
                                            , color = Vec3.vec3 1 1 0
                                            , normal = Vector3d.toVec3 point.normal
                                            }
                                        )
                                )
                                (TriangularMesh.faceIndices mesh2)
                      }
                    , Command.none
                    )

                Err error ->
                    ( model, Command.none )

        TriggeredEndXrSession ->
            ( model, Command.none )

        GotStartTime startTime ->
            ( { model | startTime = startTime }, Command.none )


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
                        { position = state.first, color = Vec3.vec3 t (1 - t) (0.5 + t / 2), normal = Vec3.vec3 0 1 0 }
                            :: { position = v, color = Vec3.vec3 t (1 - t) (0.5 + t / 2), normal = Vec3.vec3 0 1 0 }
                            :: { position = Vec3.add heightOffset v, color = Vec3.vec3 t (1 - t) (0.5 + t / 2), normal = Vec3.vec3 0 1 0 }
                            :: { position = Vec3.add heightOffset state.first, color = Vec3.vec3 t (1 - t) (0.5 + t / 2), normal = Vec3.vec3 0 1 0 }
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
    let
        elapsed =
            Duration.from model.startTime model.time
    in
    { title = "Biplane!"
    , body =
        [ Html.div
            [ Html.Attributes.style "font-size" "30px", Html.Attributes.style "font-family" "sans-serif" ]
            [ if model.isInVr then
                Html.text "Currently in VR "

              else
                Html.text "Not in VR "
            , Html.button [ Html.Events.onClick PressedEnterVr, Html.Attributes.style "font-size" "30px" ] [ Html.text "Enter VR" ]
            , " App started " ++ String.fromInt (round (Duration.inSeconds elapsed)) ++ " seconds ago" |> Html.text
            ]
        ]
    }


entities : FrontendModel -> { time : Time.Posix, xrView : WebGL.XrView, inputs : List WebGL.XrInput } -> List Entity
entities model { time, xrView, inputs } =
    [ WebGL.entity
        vertexShader
        fragmentShader
        floorAxes
        { perspective = xrView.projectionMatrix
        , viewMatrix = xrView.orientation.inverseMatrix
        , modelTransform = Mat4.identity
        , cameraPosition = xrView.orientation.position
        }

    --, WebGL.entity
    --    vertexShader
    --    fragmentShader
    --    model.boundaryMesh
    --    { perspective = xrView.projectionMatrix
    --    , viewMatrix = xrView.viewMatrixInverse
    --    , modelTransform = Mat4.identity
    --    }
    , WebGL.entity
        vertexShader
        fragmentShader
        waterMesh
        { perspective = xrView.projectionMatrix
        , viewMatrix = xrView.orientation.inverseMatrix
        , modelTransform = Mat4.identity
        , cameraPosition = xrView.orientation.position
        }
    , WebGL.entity
        vertexShader
        fragmentShader
        sunMesh
        { perspective = xrView.projectionMatrix
        , viewMatrix = xrView.orientation.inverseMatrix
        , modelTransform = Mat4.identity
        , cameraPosition = xrView.orientation.position
        }
    , WebGL.entity
        vertexShader
        fragmentShader
        sphere
        { perspective = xrView.projectionMatrix
        , viewMatrix = xrView.orientation.inverseMatrix
        , modelTransform = Mat4.identity
        , cameraPosition = Vec3.vec3 1.5 0 0 --xrView.orientation.position
        }
    , WebGL.entity
        vertexShader
        fragmentShader
        verticalLine
        { perspective = xrView.projectionMatrix
        , viewMatrix = xrView.orientation.inverseMatrix
        , modelTransform = Mat4.identity
        , cameraPosition = xrView.orientation.position
        }
    ]
        ++ List.filterMap
            (\input ->
                case ( input.orientation, input.handedness ) of
                    ( Just orientation, WebGL.RightHand ) ->
                        WebGL.entity
                            vertexShader
                            fragmentShader
                            model.biplaneMesh
                            { perspective = xrView.projectionMatrix
                            , viewMatrix = xrView.orientation.inverseMatrix
                            , modelTransform = Mat4.scale3 0.01 0.01 0.01 orientation.matrix
                            , cameraPosition = xrView.orientation.position
                            }
                            |> Just

                    _ ->
                        Nothing
            )
            inputs



--++ [ WebGL.entityWith
--        [ blend, DepthTest.default ]
--        cloudVertexShader
--        cloudFragmentShader
--        clouds
--        { perspective = xrView.projectionMatrix
--        , viewMatrix = xrView.viewMatrixInverse
--        , modelTransform = Mat4.identity
--        }
--   ]


blend : Setting
blend =
    Blend.add Blend.srcAlpha Blend.oneMinusSrcAlpha



-- Mesh


sunPosition =
    Vec3.vec3 0 500 0


sunMesh : Mesh Vertex
sunMesh =
    let
        size =
            100

        color =
            Vec3.vec3 1 1 1
    in
    [ { position = Vec3.vec3 size 0 -size |> Vec3.add sunPosition, color = color, normal = Vec3.vec3 0 1 0 }
    , { position = Vec3.vec3 size 0 size |> Vec3.add sunPosition, color = color, normal = Vec3.vec3 0 1 0 }
    , { position = Vec3.vec3 -size 0 size |> Vec3.add sunPosition, color = color, normal = Vec3.vec3 0 1 0 }
    , { position = Vec3.vec3 -size 0 -size |> Vec3.add sunPosition, color = color, normal = Vec3.vec3 0 1 0 }
    ]
        |> quadsToMesh


clouds : Mesh Vertex
clouds =
    let
        start =
            0.5

        height =
            0.3

        layers =
            30

        size =
            1
    in
    List.range 0 (layers - 1)
        |> List.concatMap
            (\index ->
                let
                    t =
                        start + height * toFloat index / layers
                in
                [ { position = Vec3.vec3 size t -size, color = Vec3.vec3 1 1 1, normal = Vec3.vec3 0 1 0 }
                , { position = Vec3.vec3 size t size, color = Vec3.vec3 1 1 1, normal = Vec3.vec3 0 1 0 }
                , { position = Vec3.vec3 -size t size, color = Vec3.vec3 1 1 1, normal = Vec3.vec3 0 1 0 }
                , { position = Vec3.vec3 -size t -size, color = Vec3.vec3 1 1 1, normal = Vec3.vec3 0 1 0 }
                ]
            )
        |> List.reverse
        |> quadsToMesh


floorAxes : Mesh Vertex
floorAxes =
    let
        thickness =
            0.05
    in
    [ { position = Vec3.vec3 1 0 -thickness, color = Vec3.vec3 1 0 0, normal = Vec3.vec3 0 1 0 }
    , { position = Vec3.vec3 1 0 thickness, color = Vec3.vec3 1 0 0, normal = Vec3.vec3 0 1 0 }
    , { position = Vec3.vec3 0 0 thickness, color = Vec3.vec3 1 0 0, normal = Vec3.vec3 0 1 0 }
    , { position = Vec3.vec3 0 0 -thickness, color = Vec3.vec3 1 0 0, normal = Vec3.vec3 0 1 0 }
    , { position = Vec3.vec3 -thickness 0 1, color = Vec3.vec3 0 0 1, normal = Vec3.vec3 0 1 0 }
    , { position = Vec3.vec3 thickness 0 1, color = Vec3.vec3 0 0 1, normal = Vec3.vec3 0 1 0 }
    , { position = Vec3.vec3 thickness 0 0, color = Vec3.vec3 0 0 1, normal = Vec3.vec3 0 1 0 }
    , { position = Vec3.vec3 -thickness 0 0, color = Vec3.vec3 0 0 1, normal = Vec3.vec3 0 1 0 }
    ]
        |> quadsToMesh


verticalLine =
    let
        thickness =
            0.02
    in
    [ { position = Vec3.vec3 0 0 -thickness, color = Vec3.vec3 0 1 0, normal = Vec3.vec3 0 1 0 }
    , { position = Vec3.vec3 0 0 thickness, color = Vec3.vec3 0 1 0, normal = Vec3.vec3 0 1 0 }
    , { position = Vec3.vec3 0 10 thickness, color = Vec3.vec3 0 1 0, normal = Vec3.vec3 0 1 0 }
    , { position = Vec3.vec3 0 10 -thickness, color = Vec3.vec3 0 1 0, normal = Vec3.vec3 0 1 0 }
    ]
        |> quadsToMesh


waterMesh : Mesh Vertex
waterMesh =
    let
        size =
            2

        color =
            Vec3.vec3 0.2 0.3 1
    in
    [ { position = Vec3.vec3 size 0 -size, color = color, normal = Vec3.vec3 0 1 0 }
    , { position = Vec3.vec3 size 0 size, color = color, normal = Vec3.vec3 0 1 0 }
    , { position = Vec3.vec3 -size 0 size, color = color, normal = Vec3.vec3 0 1 0 }
    , { position = Vec3.vec3 -size 0 -size, color = color, normal = Vec3.vec3 0 1 0 }
    ]
        |> quadsToMesh


sphere : Mesh Vertex
sphere =
    let
        radius =
            0.3

        position =
            Point3d.meters 0 0 0

        uDetail =
            32

        vDetail =
            16

        mesh =
            TriangularMesh.indexedBall
                uDetail
                vDetail
                (\u v ->
                    let
                        longitude =
                            2 * pi * toFloat u / uDetail

                        latitude =
                            pi * toFloat v / vDetail

                        point : Vector3d Meters coordinate
                        point =
                            Vector3d.meters
                                (sin longitude * sin latitude)
                                (cos latitude)
                                (cos longitude * sin latitude)
                    in
                    { position = Point3d.translateBy (Vector3d.scaleBy radius point) position |> Point3d.toVec3
                    , normal = Vector3d.toVec3 point
                    , color = Vec3.vec3 0.7 0.3 0.5
                    }
                )
    in
    WebGL.indexedTriangles (TriangularMesh.vertices mesh |> Array.toList) (TriangularMesh.faceIndices mesh)


type alias Uniforms =
    { perspective : Mat4, viewMatrix : Mat4, modelTransform : Mat4, cameraPosition : Vec3 }



-- Shaders


type alias Varying =
    { vColor : Vec3, vNormal : Vec3, vPosition : Vec3, vCameraPosition : Vec3 }


vertexShader : Shader Vertex Uniforms Varying
vertexShader =
    [glsl|
attribute vec3 position;
attribute vec3 color;
attribute vec3 normal;

uniform mat4 modelTransform;
uniform mat4 viewMatrix;
uniform mat4 perspective;
uniform vec3 cameraPosition;

varying vec3 vColor;
varying vec3 vNormal;
varying vec3 vPosition;
varying vec3 vCameraPosition;

void main(void) {
    gl_Position = perspective * viewMatrix * modelTransform * vec4(position, 1.0);
    vColor = color;
    vPosition = (modelTransform * vec4(position, 1.0)).xyz;
    vNormal = normalize((modelTransform * vec4(normal, 0.0)).xyz);
    vCameraPosition = cameraPosition;
}
    |]


fragmentShader : Shader {} a Varying
fragmentShader =
    [glsl|
precision mediump float;
varying vec3 vColor;
varying vec3 vNormal;
varying vec3 vPosition;
varying vec3 vCameraPosition;

// https://www.tomdalling.com/blog/modern-opengl/08-even-more-lighting-directional-lights-spotlights-multiple-lights/
vec3 ApplyLight(
    vec3 lightPosition,
    vec3 lightIntensities,
    float lightAmbientCoefficient,
    vec3 surfaceColor,
    vec3 normal,
    vec3 surfacePos,
    vec3 surfaceToCamera)
{
    float materialShininess = 20.0;
    vec3 materialSpecularColor = vec3(0.7, 0.7, 0.7);

    vec3 surfaceToLight = normalize(lightPosition);

    //ambient
    vec3 ambient = lightAmbientCoefficient * surfaceColor.rgb * lightIntensities;

    //diffuse
    float diffuseCoefficient = max(0.0, dot(normal, surfaceToLight));
    vec3 diffuse = diffuseCoefficient * surfaceColor.rgb * lightIntensities;

    //specular
    float specularCoefficient = 0.0;
    if (diffuseCoefficient > 0.0)
    {
        specularCoefficient = pow(max(0.0, dot(surfaceToCamera, reflect(-surfaceToLight, normal))), materialShininess);
    }
    vec3 specular = specularCoefficient * materialSpecularColor * lightIntensities;
    //linear color (color before gamma correction)
    return ambient + (diffuse + specular);
}

void main () {
    vec3 color2 =
        ApplyLight(
            vec3(0.0, 1.0, 0.0),
            vec3(1.0, 1.0, 1.0),
            0.5,
            vColor.rgb,
            normalize(vNormal),
            vPosition,
            normalize(vCameraPosition - vPosition));

    float gamma = 2.2;

    gl_FragColor = vec4(pow(color2, vec3(1.0/gamma)), 1.0);
}
    |]


cloudVertexShader : Shader Vertex Uniforms { vColor : Vec3, vPosition : Vec3 }
cloudVertexShader =
    [glsl|
attribute vec3 position;
attribute vec3 color;

uniform mat4 modelTransform;
uniform mat4 viewMatrix;
uniform mat4 perspective;

varying vec3 vColor;
varying vec3 vPosition;

void main(void) {
    gl_Position = perspective * viewMatrix * modelTransform * vec4(position, 1.0);
    vColor = color;
    vPosition = position;
}
    |]


cloudFragmentShader : Shader {} a { vColor : Vec3, vPosition : Vec3 }
cloudFragmentShader =
    [glsl|
precision mediump float;
varying vec3 vColor;
varying vec3 vPosition;

void main(void) {
    gl_FragColor = vec4(vColor, 0.1);
}
    |]
