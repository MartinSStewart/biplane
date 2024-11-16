port module Ports exposing (getDevicePixelRatio, gotConsoleLog, gotDevicePixelRatio, listenToConsole, loadSounds, playSound, pointerLockChange, repeatSound, requestPointerLock, soundsLoaded)

import Effect.Command as Command exposing (Command, FrontendOnly)
import Effect.Subscription as Subscription exposing (Subscription)
import Json.Decode
import Json.Encode


port load_sounds_to_js : Json.Encode.Value -> Cmd msg


port load_sounds_from_js : (Json.Decode.Value -> msg) -> Sub msg


port play_sound : Json.Encode.Value -> Cmd msg


port repeat_sound : Json.Encode.Value -> Cmd msg


port console_log_from_js : (Json.Decode.Value -> msg) -> Sub msg


port martinsstewart_elm_device_pixel_ratio_from_js : (Json.Decode.Value -> msg) -> Sub msg


port martinsstewart_elm_device_pixel_ratio_to_js : Json.Encode.Value -> Cmd msg


port request_pointer_lock_to_js : Json.Encode.Value -> Cmd msg


port pointer_lock_change_from_js : (Json.Decode.Value -> msg) -> Sub msg


port listen_to_console : Json.Encode.Value -> Cmd msg


listenToConsole : Command FrontendOnly toMsg msg
listenToConsole =
    Command.sendToJs "listen_to_console" listen_to_console Json.Encode.null


pointerLockChange : (Bool -> msg) -> Subscription.Subscription FrontendOnly msg
pointerLockChange msg =
    Subscription.fromJs
        "pointer_lock_change_from_js"
        pointer_lock_change_from_js
        (\value ->
            Json.Decode.decodeValue Json.Decode.bool value
                |> Result.withDefault False
                |> msg
        )


requestPointerLock : Command FrontendOnly toMsg msg
requestPointerLock =
    Command.sendToJs "request_pointer_lock_to_js" request_pointer_lock_to_js Json.Encode.null


getDevicePixelRatio : Command FrontendOnly toMsg msg
getDevicePixelRatio =
    Command.sendToJs "martinsstewart_elm_device_pixel_ratio_to_js" martinsstewart_elm_device_pixel_ratio_to_js Json.Encode.null


gotDevicePixelRatio : (Float -> msg) -> Subscription.Subscription FrontendOnly msg
gotDevicePixelRatio msg =
    Subscription.fromJs
        "martinsstewart_elm_device_pixel_ratio_from_js"
        martinsstewart_elm_device_pixel_ratio_from_js
        (\value ->
            Json.Decode.decodeValue Json.Decode.float value
                |> Result.withDefault 1
                |> msg
        )


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
        (\_ -> msg)


playSound : String -> Command FrontendOnly toMsg msg
playSound name =
    Command.sendToJs "play_sound" play_sound (Json.Encode.string name)


repeatSound : String -> Int -> Command FrontendOnly toMsg msg
repeatSound name count =
    Command.sendToJs
        "repeat_sound"
        repeat_sound
        (Json.Encode.object [ ( "name", Json.Encode.string name ), ( "count", Json.Encode.int count ) ])
