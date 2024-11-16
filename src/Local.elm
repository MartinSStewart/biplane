module Local exposing (ChangeId, Local, init, model, update, updateFromBackend)

import Dict exposing (Dict)
import Time


type Local msg model
    = Local
        { localMsgs : Dict Int { createdAt : Time.Posix, msg : msg }
        , localModel : model
        , serverModel : model
        , counter : ChangeId
        }


type ChangeId
    = ChangeId Int


increment : ChangeId -> ChangeId
increment (ChangeId a) =
    ChangeId (a + 1)


toInt : ChangeId -> Int
toInt (ChangeId a) =
    a


init : model -> Local msg model
init model2 =
    Local { localMsgs = Dict.empty, localModel = model2, serverModel = model2, counter = ChangeId 0 }


update : (msg -> model -> model) -> Time.Posix -> msg -> Local msg model -> ( ChangeId, Local msg model )
update userUpdate time msg (Local localModel_) =
    ( localModel_.counter
    , Local
        { localMsgs = Dict.insert (toInt localModel_.counter) { createdAt = time, msg = msg } localModel_.localMsgs
        , localModel = userUpdate msg localModel_.localModel
        , serverModel = localModel_.serverModel
        , counter = increment localModel_.counter
        }
    )


model : Local msg model -> model
model (Local localModel_) =
    localModel_.localModel


updateFromBackend :
    (msg -> model -> model)
    -> Maybe ChangeId
    -> msg
    -> Local msg model
    -> Local msg model
updateFromBackend userUpdate maybeChangeId msg (Local localModel_) =
    let
        newModel : model
        newModel =
            userUpdate msg localModel_.serverModel

        newLocalMsgs : Dict Int { createdAt : Time.Posix, msg : msg }
        newLocalMsgs =
            case maybeChangeId of
                Just changeId ->
                    Dict.remove (toInt changeId) localModel_.localMsgs

                Nothing ->
                    localModel_.localMsgs
    in
    Local
        { localMsgs = newLocalMsgs
        , localModel = Dict.foldl (\_ localMsg state -> userUpdate localMsg.msg state) newModel newLocalMsgs
        , serverModel = newModel
        , counter = localModel_.counter
        }
