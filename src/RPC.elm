module RPC exposing (..)

import Duration
import Json.Encode
import LamderaRPC exposing (Body(..))
import Types exposing (BackendModel, BackendMsg(..))


lamdera_handleEndpoints :
    LamderaRPC.RPCArgs
    -> BackendModel
    -> ( LamderaRPC.RPCResult, BackendModel, Cmd BackendMsg )
lamdera_handleEndpoints args model =
    case args.endpoint of
        "timing" ->
            ( LamderaRPC.ResultJson
                (Json.Encode.list
                    Json.Encode.float
                    (List.map Duration.inMilliseconds (List.reverse model.vrFrameTiming))
                )
            , model
            , Cmd.none
            )

        _ ->
            ( LamderaRPC.ResultString "", model, Cmd.none )
