module Types exposing (..)

import Angle exposing (Angle)
import Browser exposing (UrlRequest)
import Coord exposing (Coord)
import Direction2d exposing (Direction2d)
import Direction3d exposing (Direction3d)
import Duration exposing (Seconds)
import Effect.Browser.Navigation
import Effect.Time as Time
import Effect.WebGL
import Effect.WebGL.Texture exposing (Texture)
import Length exposing (Meters)
import Math.Matrix4 exposing (Mat4)
import Math.Vector2 exposing (Vec2)
import Math.Vector3 exposing (Vec3)
import Math.Vector4 exposing (Vec4)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Point3d exposing (Point3d)
import Quantity exposing (Rate, Unitless)
import SeqSet exposing (SeqSet)
import Speed exposing (MetersPerSecond)
import Url exposing (Url)
import Vector3d exposing (Vector3d)


type alias FrontendModel =
    { key : Effect.Browser.Navigation.Key
    , time : Time.Posix
    , lastVrUpdate : Time.Posix
    , isInVr : IsInVr
    , boundaryMesh : Effect.WebGL.Mesh Vertex
    , previousBoundary : Maybe (List Vec2)
    , startTime : Time.Posix
    , lagWarning : Time.Posix
    , boundaryCenter : Point2d Meters World
    , fontTexture : LoadStatus Effect.WebGL.Texture.Error Texture
    , brickSize : Coord GridUnit
    , bricks : List Brick
    , brickMesh : Effect.WebGL.Mesh BrickVertex
    , lastUsedInput : Effect.WebGL.XrHandedness
    , previousLeftInput : Input2
    , previousRightInput : Input2
    , soundsLoaded : Bool
    , consoleLog : String
    , consoleLogMesh : Effect.WebGL.Mesh LabelVertex
    , lastPlacedBrick : Maybe Brick
    , undoHeld : Maybe Time.Posix
    }


type IsInVr
    = IsInNormalMode NormalMode
    | IsInVr
    | IsInMenu


type alias NormalMode =
    { position : Point3d Meters World
    , velocity : Vector3d MetersPerSecond World
    , longitude : Angle
    , latitude : Angle
    , windowSize : Coord Pixels
    , cssWindowSize : Coord CssPixels
    , cssCanvasSize : Coord CssPixels
    , devicePixelRatio : Float
    , keysDown : SeqSet String
    , isMouseLocked : Bool
    }


type CssPixels
    = CssPixel Never


type alias Input2 =
    { trigger : Float
    , joystickButton : Bool
    , sideTrigger : Float
    , aButton : Bool
    , bButton : Bool
    , matrix : Maybe Mat4
    , joystickX : Float
    , joystickY : Float
    }


type alias Brick =
    { min : Coord GridUnit, max : Coord GridUnit, z : Int, color : Vec4, placedAt : Time.Posix }


type GridUnit
    = GridUnit Never


type alias Splash =
    { position : Point2d Meters World, createdAt : Time.Posix }


type PlaneLocal
    = PlaneLocal Never


type World
    = World Never


type alias Bullet =
    { position : Point3d Meters World
    , velocity : Vector3d (Rate Meters Seconds) World
    , firedAt : Time.Posix
    }


type LoadStatus e a
    = Loading
    | Loaded a
    | LoadError e


type alias Vertex =
    { position : Vec3
    , color : Vec4
    , normal : Vec3
    , shininess : Float
    }


type alias BrickVertex =
    { position : Vec3
    , color : Vec4
    , uvCoord : Vec2
    , size : Vec2
    , placedAt : Float
    }


type alias LabelVertex =
    { position : Vec3, texCoord : Vec2 }


type alias BackendModel =
    { message : String
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | AnimationFrame Time.Posix
    | PressedEnterVr
    | StartedXr (Result Effect.WebGL.XrStartError Effect.WebGL.XrStartData)
    | RenderedXrFrame (Result Effect.WebGL.XrRenderError Effect.WebGL.XrPose)
    | KeyDown String
    | KeyUp String
    | EndedXrSession
    | TriggeredEndXrSession
    | GotStartTime Time.Posix
    | GotFontTexture (Result Effect.WebGL.Texture.Error Texture)
    | SoundsLoaded
    | GotConsoleLog String
    | PressedEnterNormal
    | WindowResized (Coord CssPixels)
    | GotDevicePixelRatio Float
    | MouseMoved Float Float
    | MouseDown
    | PointerLockChanged Bool


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
