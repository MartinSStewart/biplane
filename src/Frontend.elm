module Frontend exposing (app)

import Array exposing (Array)
import Browser exposing (UrlRequest(..))
import Direction3d exposing (Direction3d)
import Duration exposing (Duration, Seconds)
import Effect.Browser.Events
import Effect.Browser.Navigation
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Http
import Effect.Lamdera
import Effect.Subscription as Subscription
import Effect.Task as Task
import Effect.Time as Time
import Effect.WebGL as WebGL exposing (Entity, Mesh, Shader, XrRenderError(..))
import Effect.WebGL.Settings exposing (Setting)
import Effect.WebGL.Texture exposing (Texture)
import Frame3d exposing (Frame3d)
import Geometry.Interop.LinearAlgebra.Frame3d as Frame3d
import Geometry.Interop.LinearAlgebra.Point2d as Point2d
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
import Math.Vector2 as Vec2 exposing (Vec2)
import Math.Vector3 as Vec3 exposing (Vec3)
import Obj.Decode
import Point2d
import Point3d exposing (Point3d)
import Quantity exposing (Product, Quantity, Rate)
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
            \model ->
                Subscription.batch
                    [ if model.isInVr then
                        Subscription.none

                      else
                        Effect.Browser.Events.onAnimationFrame AnimationFrame
                    , Effect.Browser.Events.onKeyDown (Json.Decode.map KeyDown (Json.Decode.field "key" Json.Decode.string))
                    ]
        , view = view
        }


init : Url.Url -> Effect.Browser.Navigation.Key -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
init url key =
    ( { key = key
      , time = Time.millisToPosix 0
      , lastVrUpdate = Time.millisToPosix 0
      , startTime = Time.millisToPosix 0
      , isInVr = False
      , boundaryMesh = WebGL.triangleFan []
      , boundaryCenter = Point2d.origin
      , previousBoundary = Nothing
      , biplaneMesh = WebGL.triangleFan []
      , islandMesh = WebGL.triangleFan []
      , cloudTexture = LoadingTexture
      , waterTexture = LoadingTexture
      , plane = Point3d.meters 0 0.5 1.5 |> Frame3d.atPoint
      , holdingHand = Nothing
      , bullets = []
      , bulletSplashes = []
      , lastShot = Time.millisToPosix 0
      , lastShotWasOnLeft = True
      , lagWarning = Time.millisToPosix 0
      }
    , Command.batch
        [ Effect.Http.get
            { url = "/biplane.obj"
            , expect = Obj.Decode.expectObj GotBiplaneObj Length.meters Obj.Decode.faces
            }
        , Effect.Http.get
            { url = "/island.obj"
            , expect = Obj.Decode.expectObj GotIslandObj Length.meters Obj.Decode.faces
            }
        , Time.now |> Task.perform GotStartTime
        , Effect.WebGL.Texture.loadWith
            { magnify = Effect.WebGL.Texture.linear
            , minify = Effect.WebGL.Texture.linear
            , horizontalWrap = Effect.WebGL.Texture.clampToEdge
            , verticalWrap = Effect.WebGL.Texture.clampToEdge
            , flipY = False
            , premultiplyAlpha = False
            }
            "/cloud-texture.png"
            |> Task.attempt GotCloudTexture
        , Effect.WebGL.Texture.loadWith
            { magnify = Effect.WebGL.Texture.linear
            , minify = Effect.WebGL.Texture.linearMipmapLinear
            , horizontalWrap = Effect.WebGL.Texture.repeat
            , verticalWrap = Effect.WebGL.Texture.repeat
            , flipY = False
            , premultiplyAlpha = False
            }
            "/ocean-texture.png"
            |> Task.attempt GotWaterTexture
        ]
    )



--cloudTexture : Effect.WebGL.Texture.Texture
--cloudTexture =
--    List.range 0 (cloudTextureSize * cloudTextureSize - 1)
--        |> List.map
--            (\index ->
--                let
--                    x =
--                        modBy cloudTextureSize index
--
--                    y =
--                        index // cloudTextureSize
--                in
--                Bytes.Encode.unsignedInt8 (modBy 256 (x + y))
--            )
--        |> Bytes.Encode.sequence
--        |> Bytes.Encode.encode
--        |> Effect.WebGL.Texture.loadBytesWith
--            { magnify = Effect.WebGL.Texture.linear
--            , minify = Effect.WebGL.Texture.linear
--            , horizontalWrap = Effect.WebGL.Texture.clampToEdge
--            , verticalWrap = Effect.WebGL.Texture.clampToEdge
--            , flipY = False
--            , premultiplyAlpha = False
--            }
--            ( cloudTextureSize, cloudTextureSize )
--            Effect.WebGL.Texture.luminance
--        |> Unsafe.assumeOk


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
            , WebGL.requestXrStart [ WebGL.clearColor 0.5 0.6 1 1, WebGL.depth 1 ] |> Task.attempt StartedXr
            )

        StartedXr result ->
            case result of
                Ok data ->
                    ( { model
                        | isInVr = True
                        , previousBoundary = data.boundary
                        , boundaryMesh = getBoundaryMesh data.boundary
                        , boundaryCenter =
                            case data.boundary of
                                Just (first :: rest) ->
                                    Point2d.centroidOf Point2d.fromVec2 first rest

                                _ ->
                                    model.boundaryCenter
                      }
                    , WebGL.renderXrFrame (entities model) |> Task.attempt RenderedXrFrame
                    )

                Err _ ->
                    ( model, Command.none )

        RenderedXrFrame result ->
            case result of
                Ok pose ->
                    vrUpdate pose model

                Err XrSessionNotStarted ->
                    ( { model | isInVr = False }, Command.none )

                Err XrLostTracking ->
                    ( model
                    , WebGL.renderXrFrame (entities model) |> Task.attempt RenderedXrFrame
                    )

        KeyDown key ->
            ( model
            , if key == "Escape" then
                WebGL.endXrSession |> Task.perform (\() -> EndedXrSession)

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
                                            , color = Vec3.vec3 0.8 0.8 0
                                            , normal = Vector3d.toVec3 point.normal
                                            , shininess = 20
                                            }
                                        )
                                )
                                (TriangularMesh.faceIndices mesh2)
                      }
                    , Command.none
                    )

                Err error ->
                    ( model, Command.none )

        GotIslandObj result ->
            case result of
                Ok mesh2 ->
                    ( { model
                        | islandMesh =
                            WebGL.indexedTriangles
                                (TriangularMesh.vertices mesh2
                                    |> Array.toList
                                    |> List.map
                                        (\point ->
                                            { position = Point3d.toVec3 point.position
                                            , color = Vec3.vec3 0.6 0.6 0.2
                                            , normal = Vector3d.toVec3 point.normal
                                            , shininess = 2
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

        GotCloudTexture result ->
            ( { model
                | cloudTexture =
                    case result of
                        Ok texture ->
                            LoadedTexture texture

                        Err error ->
                            TextureError error
              }
            , Command.none
            )

        GotWaterTexture result ->
            ( { model
                | waterTexture =
                    case result of
                        Ok texture ->
                            LoadedTexture texture

                        Err error ->
                            TextureError (Debug.log "water texture error" error)
              }
            , Command.none
            )


vrUpdate : WebGL.XrPose -> FrontendModel -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
vrUpdate pose model =
    let
        maybeInput : Maybe WebGL.XrInput
        maybeInput =
            Maybe.andThen (\index -> List.Extra.getAt index pose.inputs) model.holdingHand

        grabbed : Maybe Int
        grabbed =
            List.Extra.findIndex
                (\input ->
                    case List.Extra.getAt 1 input.buttons of
                        Just button ->
                            button.value > 0.5

                        Nothing ->
                            False
                )
                pose.inputs

        isShooting : Bool
        isShooting =
            case maybeInput of
                Just input ->
                    case List.Extra.getAt 0 input.buttons of
                        Just button ->
                            if Duration.from model.lastShot pose.time |> Quantity.lessThan (Duration.milliseconds 100) then
                                False

                            else
                                button.value > 0.5

                        Nothing ->
                            False

                Nothing ->
                    False

        newFrame : Frame3d Meters World { defines : PlaneLocal }
        newFrame =
            case Maybe.andThen .matrix maybeInput of
                Just matrix ->
                    mat4ToFrame3d matrix

                Nothing ->
                    model.plane

        elapsedTime =
            Duration.from model.lastVrUpdate pose.time

        sameBoundary =
            model.previousBoundary == pose.boundary

        ( bullets, splashes ) =
            List.foldl
                (\bullet (( bullets2, splashes2 ) as tuple) ->
                    if Duration.from bullet.firedAt pose.time |> Quantity.lessThan (Duration.seconds 2) then
                        let
                            p =
                                Point3d.translateBy (Vector3d.for elapsedTime bullet.velocity) bullet.position
                        in
                        if Point3d.zCoordinate p |> Quantity.lessThan waterZ then
                            let
                                end : { x : Float, y : Float, z : Float }
                                end =
                                    Point3d.toMeters p

                                start : { x : Float, y : Float, z : Float }
                                start =
                                    Point3d.toMeters bullet.position

                                t : Float
                                t =
                                    (Length.inMeters waterZ - start.z) / (end.z - start.z)
                            in
                            ( bullets2
                            , { position = Point2d.meters (t * (end.x - start.x) + start.x) (t * (end.y - start.y) + start.y)
                              , createdAt = pose.time
                              }
                                :: splashes2
                            )

                        else
                            ( { position = p
                              , velocity = Vector3d.for elapsedTime gravity |> Vector3d.plus bullet.velocity
                              , firedAt = bullet.firedAt
                              }
                                :: bullets2
                            , splashes2
                            )

                    else
                        tuple
                )
                ( [], model.bulletSplashes )
                model.bullets
    in
    ( { model
        | time = pose.time
        , previousBoundary = pose.boundary
        , boundaryMesh =
            if sameBoundary then
                model.boundaryMesh

            else
                getBoundaryMesh pose.boundary
        , boundaryCenter =
            if sameBoundary then
                model.boundaryCenter

            else
                case pose.boundary of
                    Just (first :: rest) ->
                        Point2d.centroidOf Point2d.fromVec2 first rest

                    _ ->
                        model.boundaryCenter
        , bullets =
            if isShooting then
                { position =
                    Frame3d.translateAlongOwn
                        Frame3d.xAxis
                        (Quantity.multiplyBy
                            (if model.lastShotWasOnLeft then
                                -worldScale

                             else
                                worldScale
                            )
                            Length.meter
                        )
                        newFrame
                        |> Frame3d.originPoint
                , velocity = Vector3d.withLength bulletSpeed (Frame3d.yDirection newFrame)
                , firedAt = pose.time
                }
                    :: bullets

            else
                bullets
        , bulletSplashes =
            List.filter
                (\splash -> Duration.from splash.createdAt pose.time |> Quantity.lessThan splashAnimDuration)
                splashes
        , lastShot =
            if isShooting then
                pose.time

            else
                model.lastShot
        , lastShotWasOnLeft =
            if isShooting then
                not model.lastShotWasOnLeft

            else
                model.lastShotWasOnLeft
        , plane = newFrame
        , lastVrUpdate = pose.time
        , lagWarning =
            if elapsedTime |> Quantity.greaterThan (Duration.milliseconds 30) then
                pose.time

            else
                model.lagWarning
        , holdingHand = grabbed
      }
    , Command.batch
        [ WebGL.renderXrFrame (entities model)
            |> Task.attempt RenderedXrFrame
        , if
            List.any
                (\input ->
                    case List.Extra.getAt menuButtonIndex input.buttons of
                        Just button ->
                            button.value >= 1

                        Nothing ->
                            False
                )
                pose.inputs
          then
            WebGL.endXrSession |> Task.perform (\() -> TriggeredEndXrSession)

          else
            Command.none
        ]
    )


gravity : Vector3d (Rate (Rate Meters Seconds) Seconds) World
gravity =
    Vector3d.xyz
        Quantity.zero
        Quantity.zero
        (Quantity.rate (Quantity.rate (Length.meters -3) Duration.second) Duration.second)


bulletSpeed : Quantity Float (Rate Meters Seconds)
bulletSpeed =
    Quantity.rate (Length.meters 15) Duration.second


mat4ToFrame3d : Mat4 -> Frame3d u c d
mat4ToFrame3d mat4 =
    let
        { m11, m12, m13, m21, m22, m23, m31, m32, m33, m14, m24, m34 } =
            Mat4.toRecord mat4
    in
    Frame3d.unsafe
        { originPoint = Point3d.unsafe { x = m14, y = m24, z = m34 }
        , xDirection = Direction3d.unsafe { x = m11, y = m21, z = m31 }
        , yDirection = Direction3d.unsafe { x = m12, y = m22, z = m32 }
        , zDirection = Direction3d.unsafe { x = m13, y = m23, z = m33 }
        }


mat4ToPoint3d : Mat4 -> Point3d u c
mat4ToPoint3d mat4 =
    let
        { m14, m24, m34 } =
            Mat4.toRecord mat4
    in
    Point3d.unsafe { x = m14, y = m24, z = m34 }


menuButtonIndex : Int
menuButtonIndex =
    12


getBoundaryMesh : Maybe (List Vec2) -> Mesh Vertex
getBoundaryMesh maybeBoundary =
    case maybeBoundary of
        Just (first :: rest) ->
            let
                heightOffset =
                    0.05

                length =
                    List.length rest + 1 |> toFloat
            in
            List.foldl
                (\v state ->
                    let
                        t =
                            state.index / length

                        x1 =
                            Vec2.getX v

                        y1 =
                            Vec2.getY v

                        x2 =
                            Vec2.getX state.first

                        y2 =
                            Vec2.getY state.first
                    in
                    { index = state.index + 1
                    , first = v
                    , quads =
                        { position = Vec3.vec3 x2 y2 0
                        , color = Vec3.vec3 t (1 - t) (0.5 + t / 2)
                        , normal = Vec3.vec3 0 1 0
                        , shininess = 20
                        }
                            :: { position = Vec3.vec3 x1 y1 0
                               , color = Vec3.vec3 t (1 - t) (0.5 + t / 2)
                               , normal = Vec3.vec3 0 1 0
                               , shininess = 20
                               }
                            :: { position = Vec3.vec3 x1 y1 heightOffset
                               , color = Vec3.vec3 t (1 - t) (0.5 + t / 2)
                               , normal = Vec3.vec3 0 1 0
                               , shininess = 20
                               }
                            :: { position = Vec3.vec3 x2 y2 heightOffset
                               , color = Vec3.vec3 t (1 - t) (0.5 + t / 2)
                               , normal = Vec3.vec3 0 1 0
                               , shininess = 20
                               }
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


waterZ =
    Length.meters 0.5


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
        [ if model.isInVr then
            Html.text "Currently in VR "

          else
            Html.div
                [ Html.Attributes.style "font-size" "30px", Html.Attributes.style "font-family" "sans-serif" ]
                [ Html.text "Not in VR "
                , Html.button [ Html.Events.onClick PressedEnterVr, Html.Attributes.style "font-size" "30px" ] [ Html.text "Enter VR" ]
                , " App started " ++ String.fromInt (round (Duration.inSeconds elapsed)) ++ " seconds ago" |> Html.text
                ]
        ]
    }


worldScaleMat =
    Mat4.makeScale3 worldScale worldScale worldScale


worldScale =
    0.01


bulletColor =
    Vec3.vec3 1 1 0.5


zNormal =
    Vec3.vec3 0 0 1


bulletsMesh : List Bullet -> Mesh Vertex
bulletsMesh bullets =
    let
        vertices =
            List.foldl
                (\bullet quads ->
                    case Vector3d.direction bullet.velocity of
                        Just dir ->
                            let
                                vDir : Vector3d Meters World
                                vDir =
                                    Vector3d.for (Duration.milliseconds 8) bullet.velocity

                                ( d1, d2 ) =
                                    Direction3d.perpendicularBasis dir

                                v1 =
                                    Direction3d.toVector d1 |> Vector3d.scaleBy 0.002 |> Vector3d.unwrap |> Vector3d.unsafe

                                v2 =
                                    Direction3d.toVector d2 |> Vector3d.scaleBy 0.002 |> Vector3d.unwrap |> Vector3d.unsafe

                                p1 =
                                    Point3d.translateBy v1 bullet.position

                                p2 =
                                    Point3d.translateBy v2 bullet.position

                                p3 =
                                    Point3d.translateBy (Vector3d.reverse v1) bullet.position

                                p4 =
                                    Point3d.translateBy (Vector3d.reverse v2) bullet.position
                            in
                            [ -- Bullet trail tail
                              { position = Point3d.toVec3 p1, color = bulletColor, normal = zNormal, shininess = 20 }
                            , { position = Point3d.toVec3 p2, color = bulletColor, normal = zNormal, shininess = 20 }
                            , { position = Point3d.toVec3 p3, color = bulletColor, normal = zNormal, shininess = 20 }
                            , { position = Point3d.toVec3 p4, color = bulletColor, normal = zNormal, shininess = 20 }
                            , -- Bullet trail head
                              { position = Point3d.translateBy vDir p1 |> Point3d.toVec3, color = bulletColor, normal = zNormal, shininess = 20 }
                            , { position = Point3d.translateBy vDir p2 |> Point3d.toVec3, color = bulletColor, normal = zNormal, shininess = 20 }
                            , { position = Point3d.translateBy vDir p3 |> Point3d.toVec3, color = bulletColor, normal = zNormal, shininess = 20 }
                            , { position = Point3d.translateBy vDir p4 |> Point3d.toVec3, color = bulletColor, normal = zNormal, shininess = 20 }
                            ]
                                ++ quads

                        Nothing ->
                            quads
                )
                []
                bullets

        indices2 : List ( Int, Int, Int )
        indices2 =
            List.foldl
                (\_ { i, indices } ->
                    { i = i + 8
                    , indices =
                        [ --tail quad
                          ( i, i + 1, i + 2 )
                        , ( i + 2, i + 3, i )
                        , -- head quad
                          ( i + 4, i + 5, i + 6 )
                        , ( i + 6, i + 7, i + 4 )
                        , -- side 1
                          ( i, i + 4, i + 1 )
                        , ( i + 1, i + 5, i + 4 )
                        , -- side 2
                          ( i + 1, i + 5, i + 6 )
                        , ( i + 1, i + 6, i + 2 )
                        , -- side 3
                          ( i + 2, i + 6, i + 3 )
                        , ( i + 6, i + 7, i + 3 )
                        , -- side 4
                          ( i + 7, i + 3, i + 4 )
                        , ( i + 4, i, i + 3 )
                        ]
                            ++ indices
                    }
                )
                { i = 0, indices = [] }
                bullets
                |> .indices
    in
    WebGL.indexedTriangles vertices indices2


entities : FrontendModel -> { time : Time.Posix, xrView : WebGL.XrView, inputs : List WebGL.XrInput } -> List Entity
entities model =
    let
        bullets =
            bulletsMesh model.bullets

        islandPos =
            Point2d.unwrap model.boundaryCenter
    in
    \{ time, xrView, inputs } ->
        let
            viewPosition =
                mat4ToPoint3d xrView.viewMatrix |> Point3d.toVec3
        in
        [ WebGL.entity
            vertexShader
            fragmentShader
            model.boundaryMesh
            { perspective = xrView.projectionMatrix
            , viewMatrix = xrView.viewMatrix
            , modelTransform = Mat4.identity
            , cameraPosition = viewPosition
            }
        , WebGL.entity
            vertexShader
            fragmentShader
            model.islandMesh
            { perspective = xrView.projectionMatrix
            , viewMatrix = xrView.viewMatrix
            , modelTransform = Mat4.mul (Mat4.makeTranslate3 islandPos.x islandPos.y (Length.inMeters waterZ)) worldScaleMat
            , cameraPosition = viewPosition
            }
        , WebGL.entity
            vertexShader
            fragmentShader
            sunMesh
            { perspective = xrView.projectionMatrix
            , viewMatrix = xrView.viewMatrix
            , modelTransform = Mat4.identity
            , cameraPosition = viewPosition
            }

        --, WebGL.entity
        --    vertexShader
        --    fragmentShader
        --    floorAxes
        --    { perspective = xrView.projectionMatrix
        --    , viewMatrix = xrView.viewMatrix
        --    , modelTransform = Mat4.identity
        --    , cameraPosition = viewPosition
        --    }
        , WebGL.entity
            vertexShader
            fragmentShader
            model.biplaneMesh
            { perspective = xrView.projectionMatrix
            , viewMatrix = xrView.viewMatrix
            , modelTransform = Mat4.mul (Frame3d.toMat4 model.plane) worldScaleMat
            , cameraPosition = viewPosition
            }
        , WebGL.entity
            vertexShader
            fragmentShader
            bullets
            { perspective = xrView.projectionMatrix
            , viewMatrix = xrView.viewMatrix
            , modelTransform = Mat4.identity
            , cameraPosition = viewPosition
            }
        ]
            ++ List.foldl
                (\splash a ->
                    let
                        splashPos =
                            Point2d.toMeters splash.position

                        elapsedTime =
                            Duration.from splash.createdAt time

                        frame : Int
                        frame =
                            Quantity.ratio elapsedTime splashAnimDuration * splashAnimFrameCount |> floor
                    in
                    case Array.get frame splashFrames of
                        Just mesh ->
                            WebGL.entity
                                vertexShader
                                fragmentShader
                                mesh
                                { perspective = xrView.projectionMatrix
                                , viewMatrix = xrView.viewMatrix
                                , modelTransform = Mat4.makeTranslate3 splashPos.x splashPos.y (Length.inMeters waterZ)
                                , cameraPosition = viewPosition
                                }
                                :: a

                        Nothing ->
                            a
                )
                []
                model.bulletSplashes
            ++ (if Duration.from model.lagWarning time |> Quantity.lessThan (Duration.milliseconds 50) then
                    [ WebGL.entityWith
                        []
                        vertexShader
                        fragmentShader
                        sphere1
                        { perspective = xrView.projectionMatrix
                        , viewMatrix = Mat4.identity
                        , modelTransform = Mat4.identity
                        , cameraPosition = viewPosition
                        }
                    ]

                else
                    []
               )
            ++ List.filterMap
                (\input ->
                    case input.matrix of
                        Just matrix ->
                            WebGL.entity
                                vertexShader
                                fragmentShader
                                splashSphere
                                { perspective = xrView.projectionMatrix
                                , viewMatrix = xrView.viewMatrix
                                , modelTransform = matrix
                                , cameraPosition = viewPosition
                                }
                                |> Just

                        Nothing ->
                            Nothing
                )
                inputs
            ++ (case model.waterTexture of
                    LoadedTexture texture ->
                        [ WebGL.entity
                            waterVertexShader
                            waterFragmentShader
                            waterMesh
                            { perspective = xrView.projectionMatrix
                            , viewMatrix = xrView.viewMatrix
                            , texture = texture
                            , time = Duration.from model.startTime time |> Duration.inSeconds
                            }
                        ]

                    _ ->
                        []
               )
            ++ (case model.cloudTexture of
                    LoadedTexture texture ->
                        [ WebGL.entityWith
                            [ blend, DepthTest.less { write = False, near = 0, far = 1 } ]
                            cloudVertexShader
                            cloudFragmentShader
                            cloudMesh
                            { perspective = xrView.projectionMatrix
                            , viewMatrix = xrView.viewMatrix
                            , modelTransform =
                                Mat4.makeTranslate3 0 0 (0.5 + Length.inMeters waterZ)
                                    |> Mat4.scale3 1 1 0.2
                            , texture = texture
                            }
                        ]

                    LoadingTexture ->
                        []

                    TextureError _ ->
                        []
               )


blend : Setting
blend =
    Blend.add Blend.srcAlpha Blend.oneMinusSrcAlpha



-- Mesh


sunPosition =
    Vec3.vec3 0 0 500


sunMesh : Mesh Vertex
sunMesh =
    let
        size =
            100

        color =
            Vec3.vec3 1 1 1
    in
    [ { position = Vec3.vec3 size -size 0 |> Vec3.add sunPosition, color = color, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 size size 0 |> Vec3.add sunPosition, color = color, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 -size size 0 |> Vec3.add sunPosition, color = color, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 -size -size 0 |> Vec3.add sunPosition, color = color, normal = zNormal, shininess = 20 }
    ]
        |> quadsToMesh


cloudMesh : Mesh CloudVertex
cloudMesh =
    let
        start =
            0

        height =
            1

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
                [ { position = Vec3.vec3 size 0 t }
                , { position = Vec3.vec3 size size t }
                , { position = Vec3.vec3 0 size t }
                , { position = Vec3.vec3 0 0 t }
                ]
            )
        |> quadsToMesh


floorAxes : Mesh Vertex
floorAxes =
    let
        thickness =
            0.01

        length =
            0.3
    in
    [ -- X axis
      { position = Vec3.vec3 length -thickness 0, color = Vec3.vec3 1 0 0, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 length thickness 0, color = Vec3.vec3 1 0 0, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 0 thickness 0, color = Vec3.vec3 1 0 0, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 0 -thickness 0, color = Vec3.vec3 1 0 0, normal = zNormal, shininess = 20 }
    , -- Y axis
      { position = Vec3.vec3 -thickness length 0, color = Vec3.vec3 0 1 0, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 thickness length 0, color = Vec3.vec3 0 1 0, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 thickness 0 0, color = Vec3.vec3 0 1 0, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 -thickness 0 0, color = Vec3.vec3 0 1 0, normal = zNormal, shininess = 20 }
    , -- Z axis
      { position = Vec3.vec3 -thickness 0 length, color = Vec3.vec3 0 0 1, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 thickness 0 length, color = Vec3.vec3 0 0 1, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 thickness 0 0, color = Vec3.vec3 0 0 1, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 -thickness 0 0, color = Vec3.vec3 0 0 1, normal = zNormal, shininess = 20 }
    ]
        |> quadsToMesh


waterMesh : Mesh WaterVertex
waterMesh =
    let
        size =
            200
    in
    [ { position = Vec3.vec3 size -size (Length.inMeters waterZ) }
    , { position = Vec3.vec3 size size (Length.inMeters waterZ) }
    , { position = Vec3.vec3 -size size (Length.inMeters waterZ) }
    , { position = Vec3.vec3 -size -size (Length.inMeters waterZ) }
    ]
        |> quadsToMesh


sphere1 : Mesh Vertex
sphere1 =
    sphere 0 (Vec3.vec3 1 0 0) (Point3d.meters 0 0 -1.2) 8


splashSphere =
    sphere 0 (Vec3.vec3 0.7 0.8 1) Point3d.origin 4


splashAnimFrameCount =
    60


splashAnimDuration =
    Duration.milliseconds 600


splashFrames : Array (Mesh Vertex)
splashFrames =
    List.range 0 (splashAnimFrameCount - 1)
        |> List.map (\i -> getSplashFrame (toFloat i / splashAnimFrameCount))
        |> Array.fromList


getSplashFrame : Float -> Mesh Vertex
getSplashFrame t =
    let
        dir =
            Direction3d.z

        position =
            Point3d.origin

        t2 =
            if t < 0.1 then
                t * 10

            else
                1 - (((t - 0.1) / 0.9) ^ 2)

        vDir : Vector3d Meters World
        vDir =
            Vector3d.meters 0 0 (worldScale * 5 * t2)

        ( d1, d2 ) =
            Direction3d.perpendicularBasis dir

        radius =
            worldScale * (0.3 + t * t * 1)

        v1 =
            Direction3d.toVector d1 |> Vector3d.scaleBy radius |> Vector3d.unwrap |> Vector3d.unsafe

        v2 =
            Direction3d.toVector d2 |> Vector3d.scaleBy radius |> Vector3d.unwrap |> Vector3d.unsafe

        p1 =
            Point3d.translateBy v1 position

        p2 =
            Point3d.translateBy v2 position

        p3 =
            Point3d.translateBy (Vector3d.reverse v1) position

        p4 =
            Point3d.translateBy (Vector3d.reverse v2) position

        splashColor =
            Vec3.vec3 0.7 0.8 1

        i =
            0
    in
    WebGL.indexedTriangles
        [ -- Bullet trail tail
          { position = Point3d.toVec3 p1, color = splashColor, normal = zNormal, shininess = 20 }
        , { position = Point3d.toVec3 p2, color = splashColor, normal = zNormal, shininess = 20 }
        , { position = Point3d.toVec3 p3, color = splashColor, normal = zNormal, shininess = 20 }
        , { position = Point3d.toVec3 p4, color = splashColor, normal = zNormal, shininess = 20 }
        , -- Bullet trail head
          { position = Point3d.translateBy vDir p1 |> Point3d.toVec3, color = splashColor, normal = zNormal, shininess = 20 }
        , { position = Point3d.translateBy vDir p2 |> Point3d.toVec3, color = splashColor, normal = zNormal, shininess = 20 }
        , { position = Point3d.translateBy vDir p3 |> Point3d.toVec3, color = splashColor, normal = zNormal, shininess = 20 }
        , { position = Point3d.translateBy vDir p4 |> Point3d.toVec3, color = splashColor, normal = zNormal, shininess = 20 }
        ]
        [ --tail quad
          ( i, i + 1, i + 2 )
        , ( i + 2, i + 3, i )
        , -- head quad
          ( i + 4, i + 5, i + 6 )
        , ( i + 6, i + 7, i + 4 )
        , -- side 1
          ( i, i + 4, i + 1 )
        , ( i + 1, i + 5, i + 4 )
        , -- side 2
          ( i + 1, i + 5, i + 6 )
        , ( i + 1, i + 6, i + 2 )
        , -- side 3
          ( i + 2, i + 6, i + 3 )
        , ( i + 6, i + 7, i + 3 )
        , -- side 4
          ( i + 7, i + 3, i + 4 )
        , ( i + 4, i, i + 3 )
        ]


sphere : Float -> Vec3 -> Point3d u c -> Int -> Mesh Vertex
sphere shininess color position detail =
    let
        radius =
            0.01

        uDetail =
            detail * 2

        vDetail =
            detail

        mesh =
            TriangularMesh.indexedBall
                uDetail
                vDetail
                (\u v ->
                    let
                        longitude =
                            2 * pi * toFloat u / toFloat uDetail

                        latitude =
                            pi * toFloat v / toFloat vDetail

                        point : Vector3d u c
                        point =
                            Vector3d.unsafe
                                { x = sin longitude * sin latitude
                                , y = cos longitude * sin latitude
                                , z = cos latitude
                                }
                    in
                    { position = Point3d.translateBy (Vector3d.scaleBy radius point) position |> Point3d.toVec3
                    , normal = Vector3d.toVec3 point
                    , color = color
                    , shininess = shininess
                    }
                )
    in
    WebGL.indexedTriangles (TriangularMesh.vertices mesh |> Array.toList) (TriangularMesh.faceIndices mesh)


type alias Uniforms =
    { perspective : Mat4, viewMatrix : Mat4, modelTransform : Mat4, cameraPosition : Vec3 }


type alias CloudUniforms =
    { perspective : Mat4, viewMatrix : Mat4, modelTransform : Mat4, texture : Texture }



-- Shaders


type alias Varying =
    { vColor : Vec3, vNormal : Vec3, vPosition : Vec3, vCameraPosition : Vec3, vShininess : Float }


waterVertexShader : Shader WaterVertex { u | perspective : Mat4, viewMatrix : Mat4 } { vPosition : Vec2 }
waterVertexShader =
    [glsl|
attribute vec3 position;

uniform mat4 viewMatrix;
uniform mat4 perspective;

varying vec2 vPosition;

void main(void) {
    gl_Position = perspective * viewMatrix * vec4(position, 1.0);
    vPosition = position.xy;
}
    |]


waterFragmentShader : Shader {} { u | texture : Texture, time : Float } { vPosition : Vec2 }
waterFragmentShader =
    [glsl|
precision mediump float;
varying vec2 vPosition;

uniform sampler2D texture;
uniform float time;

void main(void) {
    gl_FragColor =
        ( texture2D(texture, vec2(0.0123, -0.03451) * time + vPosition * 8.65621) * ((sin(time) + 2.0) / 4.0)
        + texture2D(texture, vec2(-0.023169, 0.01451) * time + vPosition * 10.0) * ((sin(time+3.1415) + 2.0) / 4.0)
        + texture2D(texture, vPosition * 3.0) / 2.0
        );
}
    |]


vertexShader : Shader Vertex Uniforms Varying
vertexShader =
    [glsl|
attribute vec3 position;
attribute vec3 color;
attribute vec3 normal;
attribute float shininess;

uniform mat4 modelTransform;
uniform mat4 viewMatrix;
uniform mat4 perspective;
uniform vec3 cameraPosition;

varying vec3 vColor;
varying vec3 vNormal;
varying vec3 vPosition;
varying vec3 vCameraPosition;
varying float vShininess;

void main(void) {
    gl_Position = perspective * viewMatrix * modelTransform * vec4(position, 1.0);
    vColor = color;
    vPosition = (modelTransform * vec4(position, 1.0)).xyz;
    vNormal = normalize((modelTransform * vec4(normal, 0.0)).xyz);
    vCameraPosition = cameraPosition;
    vShininess = shininess;
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
varying float vShininess;

// https://www.tomdalling.com/blog/modern-opengl/08-even-more-lighting-directional-lights-spotlights-multiple-lights/
vec3 ApplyLight(
    vec3 lightPosition,
    vec3 lightIntensities,
    float lightAmbientCoefficient,
    vec3 surfaceColor,
    vec3 normal,
    vec3 surfacePos,
    vec3 surfaceToCamera,
    float materialShininess)
{
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
            vec3(0.0, 0.0, 1.0),
            vec3(0.5, 0.5, 0.5),
            0.5,
            vColor.rgb,
            normalize(vNormal),
            vPosition,
            normalize(vCameraPosition - vPosition),
            vShininess);

    float gamma = 2.2;

    gl_FragColor = vec4(pow(color2, vec3(1.0/gamma)), 1.0);
}
    |]


cloudVertexShader : Shader CloudVertex CloudUniforms { vPosition : Vec3 }
cloudVertexShader =
    [glsl|
attribute vec3 position;

uniform mat4 modelTransform;
uniform mat4 viewMatrix;
uniform mat4 perspective;

varying vec3 vPosition;

void main(void) {
    gl_Position = perspective * viewMatrix * modelTransform * vec4(position, 1.0);
    vPosition = position;
}
    |]


cloudFragmentShader : Shader {} { u | texture : Texture } { vPosition : Vec3 }
cloudFragmentShader =
    [glsl|
precision mediump float;
varying vec3 vPosition;

uniform sampler2D texture;

void main(void) {
    float a = texture2D(texture, vPosition.xy).x;

    gl_FragColor = vec4(1.0, 1.0, 1.0, min(0.2, a - vPosition.z));
}
    |]
