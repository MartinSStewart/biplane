module User exposing (User, World, init)

import Length exposing (Meters)
import Point3d exposing (Point3d)
import Speed exposing (MetersPerSecond)
import Vector3d exposing (Vector3d)


type alias User =
    { position : Point3d Meters World, velocity : Vector3d MetersPerSecond World }


type World
    = World Never


init : User
init =
    { position = Point3d.origin, velocity = Vector3d.zero }
