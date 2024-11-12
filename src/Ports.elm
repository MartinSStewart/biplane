port module Ports exposing (gotConsoleLog, loadSounds, playSound, soundsLoaded)

import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Subscription as Subscription exposing (Subscription)
import Json.Decode
import Json.Encode


port load_sounds_to_js : Json.Encode.Value -> Cmd msg


port load_sounds_from_js : (Json.Decode.Value -> msg) -> Sub msg


port play_sound : Json.Encode.Value -> Cmd msg


port console_log_from_js : (Json.Decode.Value -> msg) -> Sub msg


gotConsoleLog : (String -> msg) -> Subscription FrontendOnly msg
gotConsoleLog msg =
    Subscription.fromJs
        "console_log_from_js"
        console_log_from_js
        (\value ->
            case Json.Decode.decodeValue Json.Decode.string value of
                Ok ok ->
                    msg ok

                Err error ->
                    Json.Decode.errorToString error |> msg
        )


loadSounds : Command FrontendOnly toMsg msg
loadSounds =
    Command.sendToJs "load_sounds_to_js" load_sounds_to_js Json.Encode.null


soundsLoaded : msg -> Subscription FrontendOnly msg
soundsLoaded msg =
    Subscription.fromJs
        "load_sounds_from_js"
        load_sounds_from_js
        (\value ->
            msg
        )


playSound : String -> Command FrontendOnly toMsg msg
playSound name =
    Command.sendToJs "play_sound" play_sound (Json.Encode.string name)
