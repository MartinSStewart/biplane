module Frontend exposing (app)

import Array
import Browser exposing (UrlRequest(..))
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
import Geometry.Interop.LinearAlgebra.Point3d as Point3d
import Geometry.Interop.LinearAlgebra.Vector3d as Vector3d
import Html
import Html.Attributes
import Html.Events
import Json.Decode
import Lamdera
import Length
import List.Extra
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Obj.Decode
import TriangularMesh
import Types exposing (..)
import Url
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
    , WebGL.entity
        vertexShader
        fragmentShader
        waterMesh
        { perspective = xrView.projectionMatrix
        , viewMatrix = xrView.viewMatrixInverse
        , modelTransform = Mat4.identity
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
                            , viewMatrix = xrView.viewMatrixInverse
                            , modelTransform = Mat4.scale3 0.01 0.01 0.01 orientation.matrix
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
                [ { position = vec3 size t -size, color = vec3 1 1 1, normal = Vec3.vec3 0 1 0 }
                , { position = vec3 size t size, color = vec3 1 1 1, normal = Vec3.vec3 0 1 0 }
                , { position = vec3 -size t size, color = vec3 1 1 1, normal = Vec3.vec3 0 1 0 }
                , { position = vec3 -size t -size, color = vec3 1 1 1, normal = Vec3.vec3 0 1 0 }
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
    [ { position = vec3 1 0 -thickness, color = vec3 1 0 0, normal = Vec3.vec3 0 1 0 }
    , { position = vec3 1 0 thickness, color = vec3 1 0 0, normal = Vec3.vec3 0 1 0 }
    , { position = vec3 0 0 thickness, color = vec3 1 0 0, normal = Vec3.vec3 0 1 0 }
    , { position = vec3 0 0 -thickness, color = vec3 1 0 0, normal = Vec3.vec3 0 1 0 }
    , { position = vec3 -thickness 0 1, color = vec3 0 0 1, normal = Vec3.vec3 0 1 0 }
    , { position = vec3 thickness 0 1, color = vec3 0 0 1, normal = Vec3.vec3 0 1 0 }
    , { position = vec3 thickness 0 0, color = vec3 0 0 1, normal = Vec3.vec3 0 1 0 }
    , { position = vec3 -thickness 0 0, color = vec3 0 0 1, normal = Vec3.vec3 0 1 0 }
    ]
        |> quadsToMesh


waterMesh : Mesh Vertex
waterMesh =
    let
        size =
            1000

        color =
            vec3 0.2 0.3 1
    in
    [ { position = vec3 size 0 -size, color = color, normal = Vec3.vec3 0 1 0 }
    , { position = vec3 size 0 size, color = color, normal = Vec3.vec3 0 1 0 }
    , { position = vec3 -size 0 size, color = color, normal = Vec3.vec3 0 1 0 }
    , { position = vec3 -size 0 -size, color = color, normal = Vec3.vec3 0 1 0 }
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

varying vec3 vColor;
varying vec3 vNormal;
varying vec3 vPosition;
varying vec3 vCameraPosition;

void main(void) {
    gl_Position = perspective * viewMatrix * modelTransform * vec4(position, 1.0);
    vColor = color;
    vPosition = (modelTransform * vec4(normal, 1.0)).xyz;
    vNormal = normalize((modelTransform * vec4(normal, 0.0)).xyz);
    vCameraPosition = (viewMatrix * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
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
    vec4 lightPosition,
    vec3 lightIntensities,
    float lightAmbientCoefficient,
    float lightAttenuation,
    vec3 surfaceColor,
    vec3 normal,
    vec3 surfacePos,
    vec3 surfaceToCamera)
{
    float materialShininess = 100.0;
    vec3 materialSpecularColor = vec3(0.7, 0.7, 0.7);

    vec3 surfaceToLight;

    //directional light
    surfaceToLight = normalize(lightPosition.xyz);

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
            vec4(-0.2, 0.2, 1.0, 0.0),
            vec3(0.94, 0.9, 0.7),
            0.2,
            0.0,
            vColor.rgb,
            vNormal,
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

/* discontinuous pseudorandom uniformly distributed in [-0.5, +0.5]^3 */
vec3 random3(vec3 c) {
//	float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
//	vec3 r;
//	r.z = fract(512.0*j);
//	j *= .125;
//	r.x = fract(512.0*j);
//	j *= .125;
//	r.y = fract(512.0*j);
//	return r-0.5;
    return c;
}

/* skew constants for 3d simplex functions */
const float F3 =  0.3333333;
const float G3 =  0.1666667;

/* 3d simplex noise */
float simplex3d(vec3 p) {
	 /* 1. find current tetrahedron T and it's four vertices */
	 /* s, s+i1, s+i2, s+1.0 - absolute skewed (integer) coordinates of T vertices */
	 /* x, x1, x2, x3 - unskewed coordinates of p relative to each of T vertices*/

	 /* calculate s and x */
	 vec3 s = floor(p + dot(p, vec3(F3)));
	 vec3 x = p - s + dot(s, vec3(G3));

	 /* calculate i1 and i2 */
	 vec3 e = step(vec3(0.0), x - x.yzx);
	 vec3 i1 = e*(1.0 - e.zxy);
	 vec3 i2 = 1.0 - e.zxy*(1.0 - e);

	 /* x1, x2, x3 */
	 vec3 x1 = x - i1 + G3;
	 vec3 x2 = x - i2 + 2.0*G3;
	 vec3 x3 = x - 1.0 + 3.0*G3;

	 /* 2. find four surflets and store them in d */
	 vec4 w, d;

	 /* calculate surflet weights */
	 w.x = dot(x, x);
	 w.y = dot(x1, x1);
	 w.z = dot(x2, x2);
	 w.w = dot(x3, x3);

	 /* w fades from 0.6 at the center of the surflet to 0.0 at the margin */
	 w = max(0.6 - w, 0.0);

	 /* calculate surflet components */
	 d.x = dot(random3(s), x);
	 d.y = dot(random3(s + i1), x1);
	 d.z = dot(random3(s + i2), x2);
	 d.w = dot(random3(s + 1.0), x3);

	 /* multiply d by w^4 */
	 w *= w;
	 w *= w;
	 d *= w;

	 /* 3. return the sum of the four surflets */
	 return dot(d, vec4(52.0));
}

/* directional artifacts can be reduced by rotating each octave */
float simplex3d_fractal(vec3 m) {
    return 0.5*simplex3d(m);
			//+0.1*simplex3d(2.0*m);
//			+0.1333333*simplex3d(4.0*m*rot3)
//			+0.0666667*simplex3d(8.0*m);
}

void main(void) {
    gl_FragColor = vec4(vColor, min(0.5, simplex3d_fractal(vPosition)));
}
    |]
