module Evergreen.V2.Types exposing (..)

import Angle
import Browser
import Effect.Browser.Navigation
import Effect.Lamdera
import Effect.Time
import Effect.WebGL
import Effect.WebGL.Texture
import Evergreen.V2.Color
import Evergreen.V2.Coord
import Evergreen.V2.Id
import Evergreen.V2.Point2d
import Evergreen.V2.Point3d
import Evergreen.V2.User
import Evergreen.V2.Vector3d
import Length
import List.Nonempty
import Math.Vector2
import Math.Vector3
import Math.Vector4
import Pixels
import SeqDict
import SeqSet
import Speed
import Url


type CssPixels
    = CssPixel Never


type alias NormalMode =
    { position : Evergreen.V2.Point3d.Point3d Length.Meters Evergreen.V2.User.World
    , velocity : Evergreen.V2.Vector3d.Vector3d Speed.MetersPerSecond Evergreen.V2.User.World
    , longitude : Angle.Angle
    , latitude : Angle.Angle
    , windowSize : Evergreen.V2.Coord.Coord Pixels.Pixels
    , cssWindowSize : Evergreen.V2.Coord.Coord CssPixels
    , cssCanvasSize : Evergreen.V2.Coord.Coord CssPixels
    , devicePixelRatio : Float
    , keysDown : SeqSet.SeqSet String
    , isMouseLocked : Bool
    }


type IsInVr
    = IsInNormalMode NormalMode
    | IsInVr
    | IsInMenu


type alias Vertex =
    { position : Math.Vector3.Vec3
    , color : Math.Vector4.Vec4
    , normal : Math.Vector3.Vec3
    , shininess : Float
    }


type LoadStatus e a
    = Loading
    | Loaded a
    | LoadError e


type GridUnit
    = GridUnit Never


type alias Brick =
    { min : Evergreen.V2.Coord.Coord GridUnit
    , max : Evergreen.V2.Coord.Coord GridUnit
    , z : Int
    , color : Evergreen.V2.Color.Color
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
    , position : Maybe (Evergreen.V2.Point3d.Point3d Length.Meters Evergreen.V2.User.World)
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
    , isInVr : IsInVr
    , boundaryMesh : Effect.WebGL.Mesh Vertex
    , previousBoundary : Maybe (List Math.Vector2.Vec2)
    , startTime : Effect.Time.Posix
    , lagWarning : Effect.Time.Posix
    , boundaryCenter : Evergreen.V2.Point2d.Point2d Length.Meters Evergreen.V2.User.World
    , fontTexture : LoadStatus Effect.WebGL.Texture.Error Effect.WebGL.Texture.Texture
    , brickSize : Evergreen.V2.Coord.Coord GridUnit
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
    , users : SeqDict.SeqDict (Evergreen.V2.Id.Id Evergreen.V2.Id.UserId) Evergreen.V2.User.User
    , userId : Maybe (Evergreen.V2.Id.Id Evergreen.V2.Id.UserId)
    , sentDataLastFrame : Bool
    }


type alias BackendModel =
    { users : SeqDict.SeqDict (Evergreen.V2.Id.Id Evergreen.V2.Id.UserId) Evergreen.V2.User.User
    , sessions : SeqDict.SeqDict Effect.Lamdera.SessionId (Evergreen.V2.Id.Id Evergreen.V2.Id.UserId)
    , connections : SeqDict.SeqDict Effect.Lamdera.SessionId (List.Nonempty.Nonempty Effect.Lamdera.ClientId)
    , userIdCounter : Int
    , bricks : List Brick
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
    | KeyUp String
    | EndedXrSession
    | TriggeredEndXrSession
    | GotStartTime Effect.Time.Posix
    | GotFontTexture (Result Effect.WebGL.Texture.Error Effect.WebGL.Texture.Texture)
    | SoundsLoaded
    | GotConsoleLog String
    | PressedEnterNormal
    | WindowResized (Evergreen.V2.Coord.Coord CssPixels)
    | GotDevicePixelRatio Float
    | MouseMoved Float Float
    | MouseDown
    | PointerLockChanged Bool


type ToBackend
    = NoOpToBackend
    | NewPositionRequest (Evergreen.V2.Point3d.Point3d Length.Meters Evergreen.V2.User.World) (Evergreen.V2.Vector3d.Vector3d Speed.MetersPerSecond Evergreen.V2.User.World)
    | VrUpdateRequest Evergreen.V2.User.VrUserData (List Brick)
    | ResetRequest


type BackendMsg
    = NoOpBackendMsg
    | Connected Effect.Lamdera.SessionId Effect.Lamdera.ClientId
    | Disconnected Effect.Lamdera.SessionId Effect.Lamdera.ClientId


type ToFrontend
    = NoOpToFrontend
    | UserPositionChanged (Evergreen.V2.Id.Id Evergreen.V2.Id.UserId) (Evergreen.V2.Point3d.Point3d Length.Meters Evergreen.V2.User.World) (Evergreen.V2.Vector3d.Vector3d Speed.MetersPerSecond Evergreen.V2.User.World)
    | ConnectedResponse
        (Evergreen.V2.Id.Id Evergreen.V2.Id.UserId)
        { bricks : List Brick
        , users : SeqDict.SeqDict (Evergreen.V2.Id.Id Evergreen.V2.Id.UserId) Evergreen.V2.User.User
        }
    | UserConnected (Evergreen.V2.Id.Id Evergreen.V2.Id.UserId)
    | UserDisconnected (Evergreen.V2.Id.Id Evergreen.V2.Id.UserId)
    | VrPositionChanged (Evergreen.V2.Id.Id Evergreen.V2.Id.UserId) Evergreen.V2.User.VrUserData (List Brick)
    | ResetBroadcast
