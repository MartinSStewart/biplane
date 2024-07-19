module Unsafe exposing (assumeOk)


assumeOk : Result e a -> a
assumeOk result =
    case result of
        Ok a ->
            a

        Err _ ->
            unreachable ()


{-| Be very careful when using this!
-}
unreachable : () -> a
unreachable () =
    let
        _ =
            stackOverflow 0
    in
    unreachable ()


stackOverflow : Int -> Int
stackOverflow a =
    stackOverflow a + 1
