module RPC exposing (..)

import Duration
import Http
import Json.Encode
import LamderaRPC exposing (HttpRequest)
import Types exposing (BackendModel, BackendMsg(..))


lamdera_handleEndpoints :
    Json.Encode.Value
    -> HttpRequest
    -> BackendModel
    -> ( Result Http.Error Json.Encode.Value, BackendModel, Cmd msg )
lamdera_handleEndpoints body request model =
    case request.endpoint of
        "timing" ->
            ( Json.Encode.list
                Json.Encode.float
                (List.map Duration.inMilliseconds (List.reverse model.vrFrameTiming))
                |> Ok
            , model
            , Cmd.none
            )

        _ ->
            ( Err (Http.BadBody "Endpoint not found"), model, Cmd.none )
