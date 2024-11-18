module RPC exposing (..)

import Duration
import Json.Encode
import LamderaRPC exposing (HttpRequest)
import Types exposing (BackendModel, BackendMsg(..))


lamdera_handleEndpoints :
    Json.Encode.Value
    -> HttpRequest
    -> BackendModel
    -> ( LamderaRPC.RPCResult, BackendModel, Cmd BackendMsg )
lamdera_handleEndpoints body request model =
    case request.endpoint of
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
