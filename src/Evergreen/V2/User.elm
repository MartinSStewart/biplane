module Evergreen.V2.User exposing (..)

import Evergreen.V2.Point3d
import Evergreen.V2.Vector3d
import Length
import Speed


type World
    = World Never


type alias VrUserData =
    { leftHand : Maybe (Evergreen.V2.Point3d.Point3d Length.Meters World)
    , rightHand : Maybe (Evergreen.V2.Point3d.Point3d Length.Meters World)
    , head : Evergreen.V2.Point3d.Point3d Length.Meters World
    }


type User
    = NormalUser
        { position : Evergreen.V2.Point3d.Point3d Length.Meters World
        , velocity : Evergreen.V2.Vector3d.Vector3d Speed.MetersPerSecond World
        }
    | VrUser VrUserData