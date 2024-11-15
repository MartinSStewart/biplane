module Frontend exposing (app)

import Angle
import Array exposing (Array)
import Array2D
import Axis3d
import BayerMatrix
import Browser exposing (UrlRequest(..))
import Bytes.Encode
import Camera3d
import Coord exposing (Coord)
import Dict
import Direction3d exposing (Direction3d)
import Duration exposing (Duration, Seconds)
import Effect.Browser.Dom
import Effect.Browser.Events
import Effect.Browser.Navigation
import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Lamdera
import Effect.Subscription as Subscription
import Effect.Task as Task
import Effect.Time as Time
import Effect.WebGL as WebGL exposing (Entity, Mesh, Shader, XrInput, XrRenderError(..))
import Effect.WebGL.Settings exposing (Setting)
import Effect.WebGL.Texture exposing (Texture)
import Font
import Frame3d exposing (Frame3d)
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
import List.Nonempty exposing (Nonempty)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2)
import Math.Vector3 as Vec3 exposing (Vec3)
import Math.Vector4 as Vec4 exposing (Vec4)
import Pixels exposing (Pixels)
import Point2d
import Point3d exposing (Point3d)
import Ports
import Quantity exposing (Product, Quantity(..), Rate)
import SeqSet exposing (SeqSet)
import TriangularMesh
import Types exposing (..)
import Unsafe
import Url
import Vector3d exposing (Vector3d)
import WebGL.Matrices
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
        , subscriptions = subscriptions
        , view = view
        }


subscriptions model =
    Subscription.batch
        [ case model.isInVr of
            IsInMenu ->
                Subscription.none

            IsInNormalMode _ ->
                Subscription.batch
                    [ Ports.gotDevicePixelRatio GotDevicePixelRatio
                    , Effect.Browser.Events.onResize (\width height -> WindowResized (Coord.xy width height))
                    , Effect.Browser.Events.onKeyDown (keyDecoder KeyDown)
                    , Effect.Browser.Events.onKeyUp (keyDecoder KeyUp)
                    , Effect.Browser.Events.onAnimationFrame AnimationFrame
                    , Effect.Browser.Events.onMouseMove (mouseDecoder MouseMoved)
                    , Effect.Browser.Events.onMouseDown (mouseDecoder (\_ _ -> MouseDown))
                    , Ports.pointerLockChange PointerLockChanged
                    ]

            IsInVr ->
                Effect.Browser.Events.onAnimationFrame AnimationFrame
        , Effect.Browser.Events.onKeyDown (Json.Decode.map KeyDown (Json.Decode.field "key" Json.Decode.string))
        , Ports.soundsLoaded SoundsLoaded
        , Ports.gotConsoleLog GotConsoleLog
        ]


keyDecoder : (String -> msg) -> Json.Decode.Decoder msg
keyDecoder msg =
    Json.Decode.field "key" Json.Decode.string
        |> Json.Decode.map msg


mouseDecoder : (Float -> Float -> msg) -> Json.Decode.Decoder msg
mouseDecoder msg =
    Json.Decode.map2
        msg
        (Json.Decode.field "movementX" Json.Decode.float)
        (Json.Decode.field "movementY" Json.Decode.float)


gridUnitSize : Vector3d Meters World
gridUnitSize =
    Vector3d.millimeters 32 32 20


gridZRatio : Float
gridZRatio =
    Quantity.ratio (Vector3d.zComponent gridUnitSize) (Vector3d.xComponent gridUnitSize)


brickMesh : Time.Posix -> Brick -> List BrickVertex
brickMesh startTime brick =
    let
        placedAt =
            Duration.from startTime brick.placedAt |> Duration.inMilliseconds

        color =
            brick.color

        ( Quantity minX, Quantity minY ) =
            brick.min

        ( Quantity maxX, Quantity maxY ) =
            brick.max

        gridSizeX =
            toFloat (maxX - minX)

        gridSizeY =
            toFloat (maxY - minY)

        gSize : { x : Float, y : Float, z : Float }
        gSize =
            Vector3d.toMeters gridUnitSize

        px =
            gSize.x * toFloat minX

        py =
            gSize.y * toFloat minY

        pz =
            gSize.z * toFloat brick.z

        sx =
            gSize.x * toFloat (maxX - minX)

        sy =
            gSize.y * toFloat (maxY - minY)

        sz =
            gSize.z

        v000 =
            Vec3.vec3 px py pz

        v100 =
            Vec3.vec3 (px + sx) py pz

        v010 =
            Vec3.vec3 px (py + sy) pz

        v110 =
            Vec3.vec3 (px + sx) (py + sy) pz

        v001 =
            Vec3.vec3 px py (pz + sz)

        v101 =
            Vec3.vec3 (px + sx) py (pz + sz)

        v011 =
            Vec3.vec3 px (py + sy) (pz + sz)

        v111 =
            Vec3.vec3 (px + sx) (py + sy) (pz + sz)
    in
    [ -- down
      { position = v000, color = color, uvCoord = Vec2.vec2 0 0, size = Vec2.vec2 gridSizeX gridSizeY, placedAt = placedAt }
    , { position = v100, color = color, uvCoord = Vec2.vec2 1 0, size = Vec2.vec2 gridSizeX gridSizeY, placedAt = placedAt }
    , { position = v110, color = color, uvCoord = Vec2.vec2 1 1, size = Vec2.vec2 gridSizeX gridSizeY, placedAt = placedAt }
    , { position = v010, color = color, uvCoord = Vec2.vec2 0 1, size = Vec2.vec2 gridSizeX gridSizeY, placedAt = placedAt }

    -- up
    , { position = v001, color = color, uvCoord = Vec2.vec2 0 0, size = Vec2.vec2 gridSizeX gridSizeY, placedAt = placedAt }
    , { position = v011, color = color, uvCoord = Vec2.vec2 0 1, size = Vec2.vec2 gridSizeX gridSizeY, placedAt = placedAt }
    , { position = v111, color = color, uvCoord = Vec2.vec2 1 1, size = Vec2.vec2 gridSizeX gridSizeY, placedAt = placedAt }
    , { position = v101, color = color, uvCoord = Vec2.vec2 1 0, size = Vec2.vec2 gridSizeX gridSizeY, placedAt = placedAt }

    -- left
    , { position = v000, color = color, uvCoord = Vec2.vec2 0 0, size = Vec2.vec2 gridSizeY gridZRatio, placedAt = placedAt }
    , { position = v010, color = color, uvCoord = Vec2.vec2 1 0, size = Vec2.vec2 gridSizeY gridZRatio, placedAt = placedAt }
    , { position = v011, color = color, uvCoord = Vec2.vec2 1 1, size = Vec2.vec2 gridSizeY gridZRatio, placedAt = placedAt }
    , { position = v001, color = color, uvCoord = Vec2.vec2 0 1, size = Vec2.vec2 gridSizeY gridZRatio, placedAt = placedAt }

    -- right
    , { position = v100, color = color, uvCoord = Vec2.vec2 0 0, size = Vec2.vec2 gridSizeY gridZRatio, placedAt = placedAt }
    , { position = v101, color = color, uvCoord = Vec2.vec2 0 1, size = Vec2.vec2 gridSizeY gridZRatio, placedAt = placedAt }
    , { position = v111, color = color, uvCoord = Vec2.vec2 1 1, size = Vec2.vec2 gridSizeY gridZRatio, placedAt = placedAt }
    , { position = v110, color = color, uvCoord = Vec2.vec2 1 0, size = Vec2.vec2 gridSizeY gridZRatio, placedAt = placedAt }

    -- front
    , { position = v010, color = color, uvCoord = Vec2.vec2 0 0, size = Vec2.vec2 gridSizeX gridZRatio, placedAt = placedAt }
    , { position = v110, color = color, uvCoord = Vec2.vec2 1 0, size = Vec2.vec2 gridSizeX gridZRatio, placedAt = placedAt }
    , { position = v111, color = color, uvCoord = Vec2.vec2 1 1, size = Vec2.vec2 gridSizeX gridZRatio, placedAt = placedAt }
    , { position = v011, color = color, uvCoord = Vec2.vec2 0 1, size = Vec2.vec2 gridSizeX gridZRatio, placedAt = placedAt }

    -- back
    , { position = v000, color = color, uvCoord = Vec2.vec2 0 0, size = Vec2.vec2 gridSizeX gridZRatio, placedAt = placedAt }
    , { position = v001, color = color, uvCoord = Vec2.vec2 0 1, size = Vec2.vec2 gridSizeX gridZRatio, placedAt = placedAt }
    , { position = v101, color = color, uvCoord = Vec2.vec2 1 1, size = Vec2.vec2 gridSizeX gridZRatio, placedAt = placedAt }
    , { position = v100, color = color, uvCoord = Vec2.vec2 1 0, size = Vec2.vec2 gridSizeX gridZRatio, placedAt = placedAt }
    ]


red =
    Vec4.vec4 0.8 0 0 1


init : Url.Url -> Effect.Browser.Navigation.Key -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
init url key =
    ( { key = key
      , time = Time.millisToPosix 0
      , lastVrUpdate = Time.millisToPosix 0
      , startTime = Time.millisToPosix 0
      , isInVr = IsInMenu
      , boundaryMesh = WebGL.triangleFan []
      , boundaryCenter = Point2d.origin
      , previousBoundary = Nothing
      , lagWarning = Time.millisToPosix 0
      , fontTexture = Loading
      , brickSize = Coord.xy 1 2
      , bricks = []
      , brickMesh = WebGL.indexedTriangles [] []
      , lastUsedInput = WebGL.LeftHand
      , previousLeftInput = noInput
      , previousRightInput = noInput
      , soundsLoaded = False
      , consoleLog = ""
      , consoleLogMesh = WebGL.indexedTriangles [] []
      , lastPlacedBrick = Nothing
      , undoHeld = Nothing
      }
    , Command.batch
        [ Time.now |> Task.perform GotStartTime
        , Effect.WebGL.Texture.loadWith
            { magnify = Effect.WebGL.Texture.nearest
            , minify = Effect.WebGL.Texture.linearMipmapNearest
            , horizontalWrap = Effect.WebGL.Texture.clampToEdge
            , verticalWrap = Effect.WebGL.Texture.clampToEdge
            , flipY = True
            , premultiplyAlpha = True
            }
            "/dinProMedium.png"
            |> Task.attempt GotFontTexture
        , Ports.loadSounds
        ]
    )


bayerTexture : Texture
bayerTexture =
    let
        size =
            4

        matrix =
            BayerMatrix.matrix size
    in
    List.range 0 (size * size - 1)
        |> List.map
            (\index ->
                let
                    x =
                        modBy size index

                    y =
                        index // size
                in
                Array2D.get x y matrix |> Maybe.withDefault 0 |> Bytes.Encode.unsignedInt8
            )
        |> Bytes.Encode.sequence
        |> Bytes.Encode.encode
        |> Effect.WebGL.Texture.loadBytesWith
            { magnify = Effect.WebGL.Texture.nearest
            , minify = Effect.WebGL.Texture.nearest
            , horizontalWrap = Effect.WebGL.Texture.repeat
            , verticalWrap = Effect.WebGL.Texture.repeat
            , flipY = False
            , premultiplyAlpha = False
            }
            ( size, size )
            Effect.WebGL.Texture.luminance
        |> Unsafe.assumeOk


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
            ( { model
                | time = time
                , isInVr =
                    case model.isInVr of
                        IsInNormalMode normalMode ->
                            let
                                v =
                                    Vector3d.sum
                                        [ if SeqSet.member "w" normalMode.keysDown then
                                            Vector3d.meters 1 0 0

                                          else
                                            Vector3d.zero
                                        , if SeqSet.member "s" normalMode.keysDown then
                                            Vector3d.meters -1 0 0

                                          else
                                            Vector3d.zero
                                        , if SeqSet.member "a" normalMode.keysDown then
                                            Vector3d.meters 0 1 0

                                          else
                                            Vector3d.zero
                                        , if SeqSet.member "d" normalMode.keysDown then
                                            Vector3d.meters 0 -1 0

                                          else
                                            Vector3d.zero
                                        ]
                                        |> Vector3d.normalize
                                        |> Vector3d.unwrap
                                        |> Vector3d.unsafe
                                        |> Vector3d.scaleBy 0.1
                            in
                            { normalMode
                                | position =
                                    Point3d.translateBy
                                        (Vector3d.rotateAround Axis3d.z normalMode.longitude v)
                                        normalMode.position
                            }
                                |> IsInNormalMode

                        _ ->
                            model.isInVr
              }
            , Command.none
            )

        PressedEnterVr ->
            if model.soundsLoaded then
                ( model
                , Command.batch
                    [ WebGL.requestXrStart [ WebGL.clearColor 0.5 0.6 1 1, WebGL.depth 1 ] |> Task.attempt StartedXr
                    , Ports.playSound "pop"
                    ]
                )

            else
                ( model, Command.none )

        StartedXr result ->
            case result of
                Ok data ->
                    ( { model
                        | isInVr = IsInVr
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
                    ( { model | isInVr = IsInMenu }, Command.none )

                Err XrLostTracking ->
                    ( model
                    , WebGL.renderXrFrame (entities model) |> Task.attempt RenderedXrFrame
                    )

        KeyUp key ->
            ( case model.isInVr of
                IsInNormalMode normalMode ->
                    { model
                        | isInVr =
                            IsInNormalMode { normalMode | keysDown = SeqSet.remove key normalMode.keysDown }
                    }

                _ ->
                    model
            , Command.none
            )

        KeyDown key ->
            case model.isInVr of
                IsInNormalMode normalMode ->
                    ( { model
                        | isInVr =
                            IsInNormalMode { normalMode | keysDown = SeqSet.insert key normalMode.keysDown }
                      }
                    , Command.none
                    )

                IsInVr ->
                    ( model
                    , if key == "Escape" then
                        WebGL.endXrSession |> Task.perform (\() -> EndedXrSession)

                      else
                        Command.none
                    )

                IsInMenu ->
                    ( model
                    , Command.none
                    )

        EndedXrSession ->
            ( model, Command.none )

        TriggeredEndXrSession ->
            ( model, Command.none )

        GotStartTime startTime ->
            ( { model | startTime = startTime }, Command.none )

        GotFontTexture result ->
            ( { model
                | fontTexture =
                    case result of
                        Ok texture ->
                            Loaded texture

                        Err error ->
                            LoadError (Debug.log "font texture error" error)
              }
            , Command.none
            )

        SoundsLoaded ->
            ( { model | soundsLoaded = True }, Command.none )

        GotConsoleLog log ->
            let
                log2 : String
                log2 =
                    model.consoleLog ++ "\n" ++ log |> String.right 300
            in
            ( { model
                | consoleLog = log2
                , consoleLogMesh = textMesh (Point3d.meters 0 0 -1) log2
              }
            , Command.none
            )

        PressedEnterNormal ->
            ( { model
                | isInVr =
                    IsInNormalMode
                        { position = Point3d.meters 0 0 2
                        , longitude = Quantity.zero
                        , latitude = Quantity.zero
                        , devicePixelRatio = 1
                        , windowSize = Coord.xy 100 100
                        , cssWindowSize = Coord.xy 100 100
                        , cssCanvasSize = Coord.xy 100 100
                        , keysDown = SeqSet.empty
                        , isMouseLocked = False
                        }
              }
            , Command.batch
                [ Task.perform
                    (\{ viewport } -> WindowResized (Coord.xy (round viewport.width) (round viewport.height)))
                    Effect.Browser.Dom.getViewport
                , Ports.requestPointerLock
                ]
            )

        WindowResized windowSize ->
            updateNormalMode (windowResizedUpdate windowSize) model

        GotDevicePixelRatio devicePixelRatio ->
            updateNormalMode (devicePixelRatioChanged devicePixelRatio) model

        MouseMoved x y ->
            updateNormalMode
                (\normalMode ->
                    ( if normalMode.isMouseLocked then
                        { normalMode
                            | longitude =
                                Angle.degrees (-x / 8) |> Quantity.plus normalMode.longitude
                            , latitude =
                                Quantity.plus (Angle.degrees (y / 8)) normalMode.latitude
                                    |> Quantity.clamp (Angle.degrees -89) (Angle.degrees 89)
                        }

                      else
                        normalMode
                    , Command.none
                    )
                )
                model

        MouseDown ->
            ( model
            , case model.isInVr of
                IsInNormalMode _ ->
                    Ports.requestPointerLock

                _ ->
                    Command.none
            )

        PointerLockChanged isLocked ->
            updateNormalMode (\normalMode -> ( { normalMode | isMouseLocked = isLocked }, Command.none )) model


updateNormalMode :
    (NormalMode -> ( NormalMode, Command FrontendOnly ToBackend FrontendMsg ))
    -> FrontendModel
    -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
updateNormalMode updateFunc model =
    case model.isInVr of
        IsInNormalMode normalMode ->
            let
                ( normalMode2, cmd ) =
                    updateFunc normalMode
            in
            ( { model | isInVr = IsInNormalMode normalMode2 }, cmd )

        _ ->
            ( model, Command.none )


windowResizedUpdate :
    Coord CssPixels
    -> { b | cssWindowSize : Coord CssPixels, windowSize : Coord Pixels, cssCanvasSize : Coord CssPixels, devicePixelRatio : Float }
    ->
        ( { b | cssWindowSize : Coord CssPixels, windowSize : Coord Pixels, cssCanvasSize : Coord CssPixels, devicePixelRatio : Float }
        , Command FrontendOnly ToBackend msg
        )
windowResizedUpdate cssWindowSize model =
    let
        { cssCanvasSize, windowSize } =
            findPixelPerfectSize { devicePixelRatio = model.devicePixelRatio, cssWindowSize = cssWindowSize }
    in
    ( { model | cssWindowSize = cssWindowSize, cssCanvasSize = cssCanvasSize, windowSize = windowSize }
    , Ports.getDevicePixelRatio
    )


devicePixelRatioChanged :
    Float
    -> { a | cssWindowSize : Coord CssPixels, devicePixelRatio : Float, cssCanvasSize : Coord CssPixels, windowSize : Coord Pixels }
    -> ( { a | cssWindowSize : Coord CssPixels, devicePixelRatio : Float, cssCanvasSize : Coord CssPixels, windowSize : Coord Pixels }, Command restriction toMsg msg )
devicePixelRatioChanged devicePixelRatio model =
    let
        { cssCanvasSize, windowSize } =
            findPixelPerfectSize { devicePixelRatio = devicePixelRatio, cssWindowSize = model.cssWindowSize }
    in
    ( { model | devicePixelRatio = devicePixelRatio, cssCanvasSize = cssCanvasSize, windowSize = windowSize }
    , Command.none
    )


findPixelPerfectSize :
    { devicePixelRatio : Float, cssWindowSize : Coord CssPixels }
    -> { cssCanvasSize : Coord CssPixels, windowSize : Coord Pixels }
findPixelPerfectSize frontendModel =
    let
        findValue : Quantity Int CssPixels -> ( Int, Int )
        findValue value =
            List.range 0 9
                |> List.map ((+) (Quantity.unwrap value))
                |> List.Extra.find
                    (\v ->
                        let
                            a =
                                toFloat v * frontendModel.devicePixelRatio
                        in
                        a == toFloat (round a) && modBy 2 (round a) == 0
                    )
                |> Maybe.map (\v -> ( v, toFloat v * frontendModel.devicePixelRatio |> round ))
                |> Maybe.withDefault ( Quantity.unwrap value, toFloat (Quantity.unwrap value) * frontendModel.devicePixelRatio |> round )

        ( w, actualW ) =
            findValue (Tuple.first frontendModel.cssWindowSize)

        ( h, actualH ) =
            findValue (Tuple.second frontendModel.cssWindowSize)
    in
    { cssCanvasSize = Coord.xy w h, windowSize = Coord.xy actualW actualH }


fontTextureWidth =
    1024


fontTextureHeight =
    1024


textMesh : Point3d Meters World -> String -> Mesh LabelVertex
textMesh position text =
    let
        pos =
            Point3d.toMeters position
    in
    String.foldl
        (\char ( vertices, xOffset, yOffset ) ->
            case char of
                ' ' ->
                    case Dict.get char Font.font.glyphs of
                        Just glyph ->
                            ( vertices, xOffset + glyph.xAdvance, yOffset )

                        Nothing ->
                            ( vertices, xOffset, yOffset )

                '\n' ->
                    ( vertices, 0, yOffset + 70 )

                _ ->
                    case Dict.get char Font.font.glyphs of
                        Just glyph ->
                            let
                                scaleAdjust =
                                    0.001

                                x0 =
                                    toFloat (glyph.xOffset + xOffset) * scaleAdjust + pos.x

                                y0 =
                                    -(toFloat (glyph.yOffset + yOffset) * scaleAdjust) + pos.y

                                x1 =
                                    toFloat (glyph.xOffset + glyph.width + xOffset) * scaleAdjust + pos.x

                                y1 =
                                    -(toFloat (glyph.yOffset + glyph.height + yOffset) * scaleAdjust) + pos.y

                                texX0 =
                                    toFloat glyph.x / fontTextureWidth

                                texY0 =
                                    1 - toFloat glyph.y / fontTextureHeight

                                texX1 =
                                    toFloat (glyph.x + glyph.width) / fontTextureWidth

                                texY1 =
                                    1 - toFloat (glyph.y + glyph.height) / fontTextureHeight
                            in
                            ( [ { position = Vec3.vec3 x0 y0 pos.z
                                , texCoord = Vec2.vec2 texX0 texY0
                                }
                              , { position = Vec3.vec3 x0 y1 pos.z
                                , texCoord = Vec2.vec2 texX0 texY1
                                }
                              , { position = Vec3.vec3 x1 y1 pos.z
                                , texCoord = Vec2.vec2 texX1 texY1
                                }
                              , { position = Vec3.vec3 x1 y0 pos.z
                                , texCoord = Vec2.vec2 texX1 texY0
                                }
                              ]
                                ++ vertices
                            , xOffset + glyph.xAdvance
                            , yOffset
                            )

                        Nothing ->
                            ( vertices, xOffset, yOffset )
        )
        ( [], 0, 0 )
        text
        |> (\( a, _, _ ) -> quadsToMesh a)


pointToBrick : Time.Posix -> Point3d Meters World -> Coord GridUnit -> Vec4 -> List Brick -> Brick
pointToBrick time point brickSize color existingBricks =
    let
        point2 : { x : Float, y : Float, z : Float }
        point2 =
            Point3d.toMeters point

        grid : { x : Float, y : Float, z : Float }
        grid =
            Vector3d.toMeters gridUnitSize

        gridPos : Coord GridUnit
        gridPos =
            Coord.xy
                (floor (point2.x / grid.x))
                (floor (point2.y / grid.y))

        gridZ =
            floor (point2.z / grid.z)

        a =
            { min = gridPos, max = Coord.plus brickSize gridPos }

        z =
            List.foldl
                (\brick list ->
                    if brickOverlap a brick then
                        brick.z :: list

                    else
                        list
                )
                []
                existingBricks
                |> List.sort
                |> List.foldl
                    (\z2 state ->
                        if z2 - gridZ <= 0 || z2 - state == 0 then
                            z2 + 1

                        else
                            state
                    )
                    0
    in
    { min = gridPos
    , max = Coord.plus brickSize gridPos
    , z = z
    , color = color
    , placedAt = time
    }


brickOverlap :
    { a | min : Coord GridUnit, max : Coord GridUnit }
    -> { b | min : Coord GridUnit, max : Coord GridUnit }
    -> Bool
brickOverlap a b =
    let
        ( Quantity ax0, Quantity ay0 ) =
            a.min

        ( Quantity ax1, Quantity ay1 ) =
            a.max

        ( Quantity bx0, Quantity by0 ) =
            b.min

        ( Quantity bx1, Quantity by1 ) =
            b.max
    in
    ((bx0 - ax0 <= 0 && ax0 - bx1 < 0) || (bx0 - ax1 < 0 && ax1 - bx1 <= 0))
        && ((by0 - ay0 <= 0 && ay0 - by1 < 0) || (by0 - ay1 < 0 && ay1 - by1 <= 0))


leftAndRightInputs : List XrInput -> ( Input2, Input2 )
leftAndRightInputs inputs =
    List.foldl
        (\input ( left, right ) ->
            case input.handedness of
                WebGL.LeftHand ->
                    ( inputToButtons input, right )

                WebGL.RightHand ->
                    ( left, inputToButtons input )

                WebGL.Unknown ->
                    ( left, right )
        )
        ( noInput, noInput )
        inputs


noInput : Input2
noInput =
    { trigger = 0
    , joystickButton = False
    , sideTrigger = 0
    , aButton = False
    , bButton = False
    , matrix = Nothing
    , joystickX = 0
    , joystickY = 0
    }


inputToButtons : WebGL.XrInput -> Input2
inputToButtons input =
    case ( input.buttons, input.axes ) of
        ( trigger :: sideTrigger :: _ :: joystickButton :: aButton :: bButton :: _, _ :: _ :: joystickX :: joystickY :: _ ) ->
            { trigger = trigger.value
            , joystickButton = joystickButton.isPressed
            , sideTrigger = sideTrigger.value
            , aButton = aButton.isPressed
            , bButton = bButton.isPressed
            , matrix = input.matrix
            , joystickX = joystickX
            , joystickY = joystickY
            }

        _ ->
            noInput


type PlaceBrick
    = PlaceSingle Brick
    | PlaceNone
    | PlaceMany (Nonempty Brick)


placeAdjacentBricks : Time.Posix -> Brick -> List Brick -> Nonempty Brick
placeAdjacentBricks time placedBrick existingBricks =
    let
        existingBricks2 =
            List.filter (\brick2 -> brick2.z - placedBrick.z == 0) existingBricks

        existingBricksBelow =
            List.filter (\brick2 -> brick2.z - placedBrick.z == -1) existingBricks

        newBricks =
            List.Nonempty.singleton placedBrick
    in
    placeAdjacentBricksHelper
        time
        1
        newBricks
        existingBricks2
        existingBricksBelow
        (findOpenSpots placedBrick.min placedBrick.max newBricks existingBricks2 existingBricksBelow |> SeqSet.fromList)


findOpenSpots : Coord GridUnit -> Coord GridUnit -> Nonempty Brick -> List Brick -> List Brick -> List (Coord GridUnit)
findOpenSpots brickMin brickMax newBricks existingBricks existingBricksBelow =
    List.concatMap
        (\x -> [ Coord.xy x (Coord.y brickMin - 1), Coord.xy x (Coord.y brickMax) ])
        (List.range (Coord.x brickMin) (Coord.x brickMax - 1))
        ++ List.concatMap
            (\y -> [ Coord.xy (Coord.x brickMin - 1) y, Coord.xy (Coord.x brickMax) y ])
            (List.range (Coord.y brickMin) (Coord.y brickMax - 1))
        |> List.filter
            (\coord ->
                not (List.any (brickAtPoint coord) existingBricks)
                    && not (List.Nonempty.any (brickAtPoint coord) newBricks)
                    && List.any (brickAtPoint coord) existingBricksBelow
            )


placeAdjacentBricksHelper :
    Time.Posix
    -> Int
    -> Nonempty Brick
    -> List Brick
    -> List Brick
    -> SeqSet (Coord GridUnit)
    -> Nonempty Brick
placeAdjacentBricksHelper time stepCount newBricks existingBricks existingBricksBelow openSpots =
    if stepCount > 100 then
        newBricks

    else
        case SeqSet.toList openSpots of
            brickMin :: rest ->
                let
                    brickMax : Coord GridUnit
                    brickMax =
                        Coord.plus (Coord.xy 1 1) brickMin

                    brickZ : Int
                    brickZ =
                        (List.Nonempty.head newBricks).z

                    placedAt : Time.Posix
                    placedAt =
                        Duration.addTo time (Duration.milliseconds (toFloat stepCount * 20))
                in
                case findOpenSpots brickMin brickMax newBricks existingBricks existingBricksBelow of
                    head2 :: _ ->
                        let
                            brickMin2 : Coord GridUnit
                            brickMin2 =
                                Coord.minimum head2 brickMin

                            brickMax2 : Coord GridUnit
                            brickMax2 =
                                Coord.maximum (Coord.plus (Coord.xy 1 1) head2) brickMax

                            brick : Brick
                            brick =
                                { min = brickMin2
                                , max = brickMax2
                                , z = brickZ
                                , color = green
                                , placedAt = placedAt
                                }

                            newOpenSpots : List (Coord GridUnit)
                            newOpenSpots =
                                findOpenSpots brickMin2 brickMax2 newBricks existingBricks existingBricksBelow
                        in
                        placeAdjacentBricksHelper
                            time
                            (stepCount + 1)
                            (List.Nonempty.cons brick newBricks)
                            existingBricks
                            existingBricksBelow
                            (SeqSet.union (SeqSet.fromList rest |> SeqSet.remove head2) (SeqSet.fromList newOpenSpots))

                    [] ->
                        placeAdjacentBricksHelper
                            time
                            (stepCount + 1)
                            (List.Nonempty.cons
                                { min = brickMin, max = brickMax, z = brickZ, color = green, placedAt = placedAt }
                                newBricks
                            )
                            existingBricks
                            existingBricksBelow
                            (SeqSet.fromList rest)

            [] ->
                newBricks


green =
    Vec4.vec4 0 1 0 1


brickAtPoint : Coord GridUnit -> Brick -> Bool
brickAtPoint point brick =
    let
        ( Quantity ax0, Quantity ay0 ) =
            point

        ( Quantity bx0, Quantity by0 ) =
            brick.min

        ( Quantity bx1, Quantity by1 ) =
            brick.max
    in
    (bx0 - ax0 <= 0 && ax0 - bx1 < 0) && (by0 - ay0 <= 0 && ay0 - by1 < 0)


placeBrick : Time.Posix -> Input2 -> Bool -> Bool -> FrontendModel -> PlaceBrick
placeBrick time input pressedTrigger triggerHeld model =
    case ( input.matrix, pressedTrigger, triggerHeld ) of
        ( Just matrix, True, _ ) ->
            let
                brick =
                    pointToBrick time (mat4ToPoint3d matrix) model.brickSize red model.bricks
            in
            if input.sideTrigger > 0.5 then
                placeAdjacentBricks time brick model.bricks |> PlaceMany

            else
                PlaceSingle brick

        ( Just matrix, False, True ) ->
            case model.lastPlacedBrick of
                Just lastPlacedBrick ->
                    let
                        brick =
                            pointToBrick time (mat4ToPoint3d matrix) model.brickSize red model.bricks
                    in
                    if brickOverlap lastPlacedBrick brick then
                        PlaceNone

                    else
                        PlaceSingle brick

                Nothing ->
                    PlaceNone

        _ ->
            PlaceNone


vrUpdate : WebGL.XrPose -> FrontendModel -> ( FrontendModel, Command FrontendOnly ToBackend FrontendMsg )
vrUpdate pose model =
    let
        ( leftInput, rightInput ) =
            leftAndRightInputs pose.inputs

        elapsedTime : Duration
        elapsedTime =
            Duration.from model.lastVrUpdate pose.time

        sameBoundary : Bool
        sameBoundary =
            model.previousBoundary == pose.boundary

        leftTriggerHeld : Bool
        leftTriggerHeld =
            leftInput.trigger > 0.5

        rightTriggerHeld : Bool
        rightTriggerHeld =
            rightInput.trigger > 0.5

        pressedLeftTrigger : Bool
        pressedLeftTrigger =
            leftTriggerHeld && model.previousLeftInput.trigger <= 0.5

        pressedRightTrigger : Bool
        pressedRightTrigger =
            rightTriggerHeld && model.previousRightInput.trigger <= 0.5

        maybeBrick : PlaceBrick
        maybeBrick =
            case model.lastUsedInput of
                WebGL.LeftHand ->
                    placeBrick pose.time leftInput pressedLeftTrigger leftTriggerHeld model

                WebGL.RightHand ->
                    placeBrick pose.time rightInput pressedRightTrigger rightTriggerHeld model

                WebGL.Unknown ->
                    PlaceNone

        bricks2 : List Brick
        bricks2 =
            (case maybeBrick of
                PlaceSingle brick ->
                    [ brick ]

                PlaceMany many ->
                    List.Nonempty.toList many

                PlaceNone ->
                    []
            )
                ++ model.bricks

        ( pressedUndoAt, bricks3 ) =
            case ( leftInput.aButton && not model.previousLeftInput.aButton, model.undoHeld ) of
                ( True, _ ) ->
                    ( Just pose.time, List.drop 1 bricks2 )

                ( _, Just heldAt ) ->
                    if Duration.from heldAt pose.time |> Quantity.lessThan (Duration.seconds 0.5) then
                        ( Nothing, bricks2 )

                    else
                        ( Just (Duration.addTo pose.time (Duration.seconds -0.35)), List.drop 1 bricks2 )

                _ ->
                    ( Nothing, bricks2 )

        brickSizeX : Int
        brickSizeX =
            if leftInput.joystickX > 0.5 && model.previousLeftInput.joystickX <= 0.5 then
                Coord.x model.brickSize + 1 |> min 4

            else if leftInput.joystickX < -0.5 && model.previousLeftInput.joystickX >= -0.5 then
                Coord.x model.brickSize - 1 |> max 1

            else
                Coord.x model.brickSize

        brickSizeY : Int
        brickSizeY =
            if leftInput.joystickY > 0.5 && model.previousLeftInput.joystickY <= 0.5 then
                Coord.y model.brickSize - 1 |> max 1

            else if leftInput.joystickY < -0.5 && model.previousLeftInput.joystickY >= -0.5 then
                Coord.y model.brickSize + 1 |> min 4

            else
                Coord.y model.brickSize

        brickSize2 : Coord units
        brickSize2 =
            Coord.xy brickSizeX brickSizeY
    in
    ( { key = model.key
      , time = pose.time
      , isInVr = model.isInVr
      , fontTexture = model.fontTexture
      , brickSize =
            if rightInput.aButton && not model.previousRightInput.aButton then
                Coord.xy (Coord.y brickSize2) (Coord.x brickSize2)

            else
                brickSize2
      , bricks = bricks3
      , brickMesh =
            if maybeBrick /= PlaceNone || pressedUndoAt /= Nothing then
                List.foldr (\brick mesh -> brickMesh model.startTime brick ++ mesh) [] bricks3 |> quadsToMesh

            else
                model.brickMesh
      , startTime = model.startTime
      , previousBoundary = pose.boundary
      , lastUsedInput =
            if pressedLeftTrigger then
                WebGL.LeftHand

            else if pressedRightTrigger then
                WebGL.RightHand

            else
                model.lastUsedInput
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
      , lastVrUpdate = pose.time
      , lagWarning =
            if elapsedTime |> Quantity.greaterThan (Duration.milliseconds 30) then
                pose.time

            else
                model.lagWarning
      , previousLeftInput = leftInput
      , previousRightInput = rightInput
      , soundsLoaded = model.soundsLoaded
      , consoleLog = model.consoleLog
      , consoleLogMesh = model.consoleLogMesh
      , lastPlacedBrick =
            case maybeBrick of
                PlaceSingle brick ->
                    Just brick

                PlaceMany many ->
                    Just (List.Nonempty.last many)

                PlaceNone ->
                    case ( model.lastUsedInput, leftTriggerHeld, rightTriggerHeld ) of
                        ( WebGL.LeftHand, False, _ ) ->
                            Nothing

                        ( WebGL.RightHand, _, False ) ->
                            Nothing

                        ( _, False, False ) ->
                            Nothing

                        _ ->
                            model.lastPlacedBrick
      , undoHeld =
            case pressedUndoAt of
                Just pressedAt ->
                    Just pressedAt

                Nothing ->
                    if leftInput.aButton then
                        model.undoHeld

                    else
                        Nothing
      }
    , Command.batch
        [ WebGL.renderXrFrame (entities model) |> Task.attempt RenderedXrFrame
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
        , case maybeBrick of
            PlaceSingle _ ->
                Ports.playSound "resize-brick"

            PlaceMany many ->
                Ports.repeatSound "resize-brick" (List.Nonempty.length many)

            PlaceNone ->
                Command.none
        , case pressedUndoAt of
            Just _ ->
                Ports.playSound "undo"

            Nothing ->
                Command.none
        ]
    )


gravity : Vector3d (Rate (Rate Meters Seconds) Seconds) World
gravity =
    Vector3d.xyz
        Quantity.zero
        Quantity.zero
        (Quantity.rate (Quantity.rate (Length.meters -3) Duration.second) Duration.second)


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
                        , color = Vec4.vec4 t (1 - t) (0.5 + t / 2) 1
                        , normal = Vec3.vec3 0 1 0
                        , shininess = 20
                        }
                            :: { position = Vec3.vec3 x1 y1 0
                               , color = Vec4.vec4 t (1 - t) (0.5 + t / 2) 1
                               , normal = Vec3.vec3 0 1 0
                               , shininess = 20
                               }
                            :: { position = Vec3.vec3 x1 y1 heightOffset
                               , color = Vec4.vec4 t (1 - t) (0.5 + t / 2) 1
                               , normal = Vec3.vec3 0 1 0
                               , shininess = 20
                               }
                            :: { position = Vec3.vec3 x2 y2 heightOffset
                               , color = Vec4.vec4 t (1 - t) (0.5 + t / 2) 1
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
    { title = "Brick collab"
    , body =
        [ case model.isInVr of
            IsInVr ->
                Html.text "Currently in VR "

            IsInNormalMode normalMode ->
                normalModeView normalMode model

            IsInMenu ->
                Html.div
                    [ Html.Attributes.style "font-size" "30px", Html.Attributes.style "font-family" "sans-serif" ]
                    [ if model.soundsLoaded then
                        Html.div
                            []
                            [ Html.text "Not in VR "
                            , Html.button
                                [ Html.Events.onClick PressedEnterVr, Html.Attributes.style "font-size" "30px" ]
                                [ Html.text "Enter VR game" ]
                            , Html.div
                                [ Html.Attributes.style "padding" "20px" ]
                                [ Html.button
                                    [ Html.Events.onClick PressedEnterNormal, Html.Attributes.style "font-size" "30px" ]
                                    [ Html.text "Enter normal game" ]
                                ]
                            ]

                      else
                        Html.text "(Loading...)"
                    , " App started " ++ String.fromInt (round (Duration.inSeconds elapsed)) ++ " seconds ago" |> Html.text
                    ]
        , Html.node "style" [] [ Html.text "body { overflow: hidden; margin: 0; }" ]
        ]
    }


normalModeView : NormalMode -> FrontendModel -> Html.Html msg
normalModeView normalMode model =
    let
        camera =
            Camera3d.lookAt
                { eyePoint = normalMode.position
                , focalPoint =
                    Point3d.translateIn
                        (Direction3d.rotateAround Axis3d.y normalMode.latitude Direction3d.x
                            |> Direction3d.rotateAround Axis3d.z normalMode.longitude
                        )
                        Length.meter
                        normalMode.position
                , projection = Camera3d.Perspective
                , fov = Camera3d.angle (Angle.degrees 80)
                , upDirection = Direction3d.z
                }

        perspective : Mat4
        perspective =
            WebGL.Matrices.projectionMatrix
                camera
                { nearClipDepth = Length.centimeters 10
                , farClipDepth = Length.kilometer
                , aspectRatio = toFloat windowWidth / toFloat windowHeight
                }

        viewMatrix : Mat4
        viewMatrix =
            WebGL.Matrices.viewMatrix camera

        ( windowWidth, windowHeight ) =
            Coord.toTuple normalMode.windowSize

        ( cssWindowWidth, cssWindowHeight ) =
            Coord.toTuple normalMode.cssCanvasSize
    in
    WebGL.toHtmlWith
        [ WebGL.clearColor 1 1 0.9 1 ]
        [ Html.Attributes.width windowWidth
        , Html.Attributes.height windowHeight
        , Html.Attributes.style "width" (String.fromInt cssWindowWidth ++ "px")
        , Html.Attributes.style "height" (String.fromInt cssWindowHeight ++ "px")
        ]
        [ WebGL.entity
            vertexShader
            fragmentShader
            sphere2
            { perspective = perspective
            , viewMatrix = viewMatrix
            , modelTransform = Mat4.identity
            , cameraPosition = Point3d.toVec3 normalMode.position
            }
        , WebGL.entity
            vertexShader
            fragmentShader
            square2
            { perspective = perspective
            , viewMatrix = viewMatrix
            , modelTransform = Mat4.identity
            , cameraPosition = Point3d.toVec3 normalMode.position
            }
        ]


zNormal =
    Vec3.vec3 0 0 1


clearScreen : Entity
clearScreen =
    WebGL.entityWith
        [ DepthTest.always { write = True, near = 0, far = 1 } ]
        flatVertexShader
        flatFragmentShader
        (quadsToMesh
            [ { position = Vec2.vec2 -1 -1 }
            , { position = Vec2.vec2 1 -1 }
            , { position = Vec2.vec2 1 1 }
            , { position = Vec2.vec2 -1 1 }
            ]
        )
        {}


entities : FrontendModel -> { time : Time.Posix, xrView : WebGL.XrView, inputs : List WebGL.XrInput } -> List Entity
entities model =
    \{ time, xrView, inputs } ->
        let
            viewPosition : Vec3
            viewPosition =
                mat4ToPoint3d xrView.viewMatrix |> Point3d.toVec3

            ( leftInput, rightInput ) =
                leftAndRightInputs inputs
        in
        [ clearScreen
        ]
            ++ (case model.fontTexture of
                    Loaded fontTexture ->
                        [ --WebGL.entityWith
                          --    [ premultipliedBlend
                          --    ]
                          --    labelVertexShader
                          --    labelFragmentShader
                          --    helloWorld
                          --    { perspective = xrView.projectionMatrix
                          --    , viewMatrix = Mat4.identity --xrView.viewMatrix
                          --    , fontTexture = fontTexture
                          --    }
                          WebGL.entityWith
                            [ premultipliedBlend
                            ]
                            labelVertexShader
                            labelFragmentShader
                            model.consoleLogMesh
                            { perspective = xrView.projectionMatrix
                            , viewMatrix = xrView.viewMatrix
                            , fontTexture = fontTexture
                            }
                        , WebGL.entity
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
                            floorAxes
                            { perspective = xrView.projectionMatrix
                            , viewMatrix = xrView.viewMatrix
                            , modelTransform = Mat4.identity
                            , cameraPosition = viewPosition
                            }
                        , WebGL.entityWith
                            [ DepthTest.default
                            , Effect.WebGL.Settings.cullFace Effect.WebGL.Settings.back
                            , blend
                            ]
                            brickVertexShader
                            brickFragmentShader
                            model.brickMesh
                            { perspective = xrView.projectionMatrix
                            , viewMatrix = xrView.viewMatrix
                            , modelTransform = Mat4.identity
                            , elapsedTime = Duration.from model.startTime time |> Duration.inMilliseconds
                            }
                        ]
                            ++ (case model.lastUsedInput of
                                    WebGL.LeftHand ->
                                        case leftInput.matrix of
                                            Just matrix ->
                                                [ drawPreviewBrick viewPosition xrView matrix model ]

                                            Nothing ->
                                                []

                                    WebGL.RightHand ->
                                        case rightInput.matrix of
                                            Just matrix ->
                                                [ drawPreviewBrick viewPosition xrView matrix model ]

                                            Nothing ->
                                                []

                                    WebGL.Unknown ->
                                        []
                               )

                    _ ->
                        []
               )
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


drawPreviewBrick : Vec3 -> WebGL.XrView -> Mat4 -> FrontendModel -> Entity
drawPreviewBrick viewPosition xrView matrix model =
    WebGL.entityWith
        [ DepthTest.default
        , Effect.WebGL.Settings.cullFace Effect.WebGL.Settings.back
        , blend
        ]
        brickVertexShader
        brickFragmentShader
        (pointToBrick
            (Time.millisToPosix 0)
            (mat4ToPoint3d matrix)
            model.brickSize
            (Vec4.vec4 0.2 0.2 1 0.3)
            model.bricks
            |> brickMesh (Time.millisToPosix 0)
            |> quadsToMesh
        )
        { perspective = xrView.projectionMatrix
        , viewMatrix = xrView.viewMatrix
        , modelTransform = Mat4.identity
        , cameraPosition = viewPosition
        , elapsedTime = 1000
        }


blend : Setting
blend =
    Blend.add Blend.srcAlpha Blend.oneMinusSrcAlpha


premultipliedBlend : Setting
premultipliedBlend =
    Blend.add Blend.one Blend.oneMinusSrcAlpha



-- Mesh


square : Mesh LabelVertex
square =
    [ { position = Vec3.vec3 2 0 0, texCoord = Vec2.vec2 0 0 }
    , { position = Vec3.vec3 2 2 0, texCoord = Vec2.vec2 1 0 }
    , { position = Vec3.vec3 0 2 0, texCoord = Vec2.vec2 1 1 }
    , { position = Vec3.vec3 0 0 0, texCoord = Vec2.vec2 0 1 }
    ]
        |> quadsToMesh


square2 : Mesh Vertex
square2 =
    [ { position = Vec3.vec3 100 0 0, color = green, normal = Vec3.vec3 0 0 1, shininess = 1 }
    , { position = Vec3.vec3 100 100 0, color = green, normal = Vec3.vec3 0 0 1, shininess = 1 }
    , { position = Vec3.vec3 0 100 0, color = green, normal = Vec3.vec3 0 0 1, shininess = 1 }
    , { position = Vec3.vec3 0 0 0, color = green, normal = Vec3.vec3 0 0 1, shininess = 1 }
    ]
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
      { position = Vec3.vec3 length -thickness 0, color = Vec4.vec4 1 0 0 1, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 length thickness 0, color = Vec4.vec4 1 0 0 1, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 0 thickness 0, color = Vec4.vec4 1 0 0 1, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 0 -thickness 0, color = Vec4.vec4 1 0 0 1, normal = zNormal, shininess = 20 }
    , -- Y axis
      { position = Vec3.vec3 -thickness length 0, color = Vec4.vec4 0 1 0 1, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 thickness length 0, color = Vec4.vec4 0 1 0 1, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 thickness 0 0, color = Vec4.vec4 0 1 0 1, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 -thickness 0 0, color = Vec4.vec4 0 1 0 1, normal = zNormal, shininess = 20 }
    , -- Z axis
      { position = Vec3.vec3 -thickness 0 length, color = Vec4.vec4 0 0 1 1, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 thickness 0 length, color = Vec4.vec4 0 0 1 1, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 thickness 0 0, color = Vec4.vec4 0 0 1 1, normal = zNormal, shininess = 20 }
    , { position = Vec3.vec3 -thickness 0 0, color = Vec4.vec4 0 0 1 1, normal = zNormal, shininess = 20 }
    ]
        |> quadsToMesh


sphere1 : Mesh Vertex
sphere1 =
    sphere 0 (Vec4.vec4 1 0 0 1) (Point3d.meters 0 0 -1.2) 0.01 8


sphere2 : Mesh Vertex
sphere2 =
    sphere 0 (Vec4.vec4 1 0 0 1) (Point3d.meters 0 0 -1.2) 1.3 8


sphere : Float -> Vec4 -> Point3d u c -> Float -> Int -> Mesh Vertex
sphere shininess color position radius detail =
    let
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



-- Shaders


type alias Varying =
    { vColor : Vec4, vNormal : Vec3, vPosition : Vec3, vCameraPosition : Vec3, vShininess : Float }


type alias BrickVarying =
    { vColor : Vec4, vPosition : Vec3, vUvCoord : Vec2, vSize : Vec2 }


brickVertexShader : Shader BrickVertex { a | elapsedTime : Float, perspective : Mat4, viewMatrix : Mat4, modelTransform : Mat4 } BrickVarying
brickVertexShader =
    [glsl|
attribute vec3 position;
attribute vec4 color;
attribute vec2 uvCoord;
attribute vec2 size;
attribute float placedAt;

uniform mat4 modelTransform;
uniform mat4 viewMatrix;
uniform mat4 perspective;
uniform float elapsedTime;

varying vec4 vColor;
varying vec3 vPosition;
varying vec2 vUvCoord;
varying vec2 vSize;

void main(void) {
    float t = clamp((elapsedTime - placedAt) / 100.0, 0.0, 1.0);
    gl_Position = perspective * viewMatrix * modelTransform * vec4(position.xy, position.z + (1.0 - t) / 15.0, 1.0);
    vColor = vec4(color.rgb, color.a * t);
    vPosition = (modelTransform * vec4(position, 1.0)).xyz;
    vUvCoord = uvCoord;
    vSize = size;
}
    |]


brickFragmentShader : Shader {} a BrickVarying
brickFragmentShader =
    [glsl|
precision mediump float;
varying vec4 vColor;
varying vec3 vPosition;
varying vec2 vUvCoord;
varying vec2 vSize;

void main () {
    vec2 tVec = vUvCoord;
    vec2 threshold = 0.05 / vSize;
    gl_FragColor =
        vec4(vColor.rgb *
            ((tVec.x < threshold.x
                || tVec.x > (1.0 - threshold.x)
                || tVec.y < threshold.y
                || tVec.y > (1.0 - threshold.y))
                    ? 0.7
                    : 1.0)
            , vColor.a);
}
    |]


vertexShader : Shader Vertex Uniforms Varying
vertexShader =
    [glsl|
attribute vec3 position;
attribute vec4 color;
attribute vec3 normal;
attribute float shininess;

uniform mat4 modelTransform;
uniform mat4 viewMatrix;
uniform mat4 perspective;
uniform vec3 cameraPosition;

varying vec4 vColor;
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
varying vec4 vColor;
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
            vec3(0.3, 0.5, 1.0),
            vec3(0.5, 0.5, 0.5),
            0.5,
            vColor.rgb,
            normalize(vNormal),
            vPosition,
            normalize(vCameraPosition - vPosition),
            vShininess);

    float gamma = 2.2;

    gl_FragColor = vec4(pow(color2, vec3(1.0/gamma)), vColor.a);
}
    |]


flatVertexShader : Shader { position : Vec2 } u {}
flatVertexShader =
    [glsl|
attribute vec2 position;

void main(void) {
    gl_Position = vec4(position, 1.0, 1.0);
}
    |]


flatFragmentShader : Shader {} u {}
flatFragmentShader =
    [glsl|
precision mediump float;

void main(void) {
    gl_FragColor = vec4(0.5, 0.6, 1.0, 1.0);
}
    |]


labelVertexShader : Shader LabelVertex { a | viewMatrix : Mat4, perspective : Mat4 } { vTexCoord : Vec2 }
labelVertexShader =
    [glsl|
attribute vec3 position;
attribute vec2 texCoord;

uniform mat4 viewMatrix;
uniform mat4 perspective;

varying vec2 vTexCoord;

void main () {
  gl_Position = perspective * viewMatrix * vec4(position, 1.0);
  vTexCoord = texCoord;
}

|]


labelFragmentShader : Shader {} { a | fontTexture : Texture } { vTexCoord : Vec2 }
labelFragmentShader =
    [glsl|
        precision mediump float;
        uniform sampler2D fontTexture;
        varying vec2 vTexCoord;

        void main () {
            gl_FragColor = texture2D(fontTexture, vTexCoord);
        }
    |]
