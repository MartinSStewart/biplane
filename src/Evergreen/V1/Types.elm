module Evergreen.V1.Types exposing (..)

import Browser
import Effect.Browser.Navigation
import Effect.Time
import Effect.WebGL
import Effect.WebGL.Texture
import Evergreen.V1.Coord
import Evergreen.V1.Point2d
import Length
import Math.Matrix4
import Math.Vector2
import Math.Vector3
import Math.Vector4
import Url


type alias Vertex =
    { position : Math.Vector3.Vec3
    , color : Math.Vector4.Vec4
    , normal : Math.Vector3.Vec3
    , shininess : Float
    }


type World
    = World Never


type LoadStatus e a
    = Loading
    | Loaded a
    | LoadError e


type GridUnit
    = GridUnit Never


type alias Brick =
    { min : Evergreen.V1.Coord.Coord GridUnit
    , max : Evergreen.V1.Coord.Coord GridUnit
    , z : Int
    , color : Math.Vector4.Vec4
    , placedAt : Effect.Time.Posix
    }


type alias BrickVertex =
    { position : Math.Vector3.Vec3
    , color : Math.Vector4.Vec4
    , uvCoord : Math.Vector2.Vec2
    , size : Math.Vector2.Vec2
    , placedAt : Float
    }


type alias Input2 =
    { trigger : Float
    , joystickButton : Bool
    , sideTrigger : Float
    , aButton : Bool
    , bButton : Bool
    , matrix : Maybe Math.Matrix4.Mat4
    , joystickX : Float
    , joystickY : Float
    }


type alias LabelVertex =
    { position : Math.Vector3.Vec3
    , texCoord : Math.Vector2.Vec2
    }


type alias FrontendModel =
    { key : Effect.Browser.Navigation.Key
    , time : Effect.Time.Posix
    , lastVrUpdate : Effect.Time.Posix
    , isInVr : Bool
    , boundaryMesh : Effect.WebGL.Mesh Vertex
    , previousBoundary : Maybe (List Math.Vector2.Vec2)
    , startTime : Effect.Time.Posix
    , lagWarning : Effect.Time.Posix
    , boundaryCenter : Evergreen.V1.Point2d.Point2d Length.Meters World
    , fontTexture : LoadStatus Effect.WebGL.Texture.Error Effect.WebGL.Texture.Texture
    , brickSize : Evergreen.V1.Coord.Coord GridUnit
    , bricks : List Brick
    , brickMesh : Effect.WebGL.Mesh BrickVertex
    , lastUsedInput : Effect.WebGL.XrHandedness
    , previousLeftInput : Input2
    , previousRightInput : Input2
    , soundsLoaded : Bool
    , consoleLog : String
    , consoleLogMesh : Effect.WebGL.Mesh LabelVertex
    , lastPlacedBrick : Maybe Brick
    , undoHeld : Maybe Effect.Time.Posix
    }


type alias BackendModel =
    { message : String
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | AnimationFrame Effect.Time.Posix
    | PressedEnterVr
    | StartedXr (Result Effect.WebGL.XrStartError Effect.WebGL.XrStartData)
    | RenderedXrFrame (Result Effect.WebGL.XrRenderError Effect.WebGL.XrPose)
    | KeyDown String
    | EndedXrSession
    | TriggeredEndXrSession
    | GotStartTime Effect.Time.Posix
    | GotFontTexture (Result Effect.WebGL.Texture.Error Effect.WebGL.Texture.Texture)
    | SoundsLoaded
    | GotConsoleLog String


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
