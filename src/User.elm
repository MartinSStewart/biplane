module User exposing (User(..), VrUserData, World, init)

import Length exposing (Meters)
import Point3d exposing (Point3d)
import Speed exposing (MetersPerSecond)
import Vector3d exposing (Vector3d)


type User
    = NormalUser { position : Point3d Meters World, velocity : Vector3d MetersPerSecond World }
    | VrUser VrUserData


type alias VrUserData =
    { leftHand : Maybe (Point3d Meters World)
    , rightHand : Maybe (Point3d Meters World)
    , head : Point3d Meters World
    }


type World
    = World Never


init : User
init =
    NormalUser { position = Point3d.origin, velocity = Vector3d.zero }
