module Evergreen.V6.Geometry.Types exposing (..)


type Point3d units coordinates
    = Point3d
        { x : Float
        , y : Float
        , z : Float
        }


type Vector3d units coordinates
    = Vector3d
        { x : Float
        , y : Float
        , z : Float
        }


type Point2d units coordinates
    = Point2d
        { x : Float
        , y : Float
        }
