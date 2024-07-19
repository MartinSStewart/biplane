module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Effect.Browser.Navigation
import Effect.Http
import Effect.Time as Time
import Effect.WebGL
import Effect.WebGL.Texture exposing (Texture)
import Length exposing (Meters)
import Math.Vector2 exposing (Vec2)
import Math.Vector3 exposing (Vec3)
import Obj.Decode exposing (ObjCoordinates)
import Point3d exposing (Point3d)
import Quantity exposing (Unitless)
import TriangularMesh exposing (TriangularMesh)
import Url exposing (Url)
import Vector3d exposing (Vector3d)


type alias FrontendModel =
    { key : Effect.Browser.Navigation.Key
    , time : Time.Posix
    , isInVr : Bool
    , boundaryMesh : Effect.WebGL.Mesh Vertex
    , previousBoundary : Maybe (List Vec2)
    , biplaneMesh : Effect.WebGL.Mesh Vertex
    , startTime : Time.Posix
    , cloudTexture : TextureStatus
    }


type TextureStatus
    = LoadingTexture
    | LoadedTexture Texture
    | TextureError Effect.WebGL.Texture.Error


type alias Vertex =
    { position : Vec3
    , color : Vec3
    , normal : Vec3
    }


type alias CloudVertex =
    { position : Vec3
    }


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
    | EndedXrSession
    | GotBiplaneObj (Result Effect.Http.Error (TriangularMesh { position : Point3d Meters ObjCoordinates, normal : Vector3d Unitless ObjCoordinates }))
    | TriggeredEndXrSession
    | GotStartTime Time.Posix
    | GotCloudTexture (Result Effect.WebGL.Texture.Error Texture)


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
