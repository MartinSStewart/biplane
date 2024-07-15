module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Effect.Browser.Navigation
import Effect.Http
import Effect.Time as Time
import Effect.WebGL
import Length exposing (Meters)
import Math.Vector3 exposing (Vec3)
import Obj.Decode
import Point3d exposing (Point3d)
import TriangularMesh exposing (TriangularMesh)
import Url exposing (Url)


type alias FrontendModel =
    { key : Effect.Browser.Navigation.Key
    , time : Time.Posix
    , isInVr : Bool
    , boundaryMesh : Effect.WebGL.Mesh Vertex
    , previousBoundary : Maybe (List Vec3)
    , biplaneMesh : Effect.WebGL.Mesh Vertex
    }


type alias Vertex =
    { position : Vec3
    , color : Vec3
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
    | GotBiplaneObj (Result Effect.Http.Error (TriangularMesh (Point3d Meters Obj.Decode.ObjCoordinates)))


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
