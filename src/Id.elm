module Id exposing
    ( Id(..)
    , UserId
    , fromInt
    , toString
    )


type UserId
    = UserId Never


type Id a
    = Id Int


fromInt : Int -> Id a
fromInt =
    Id


toString : Id a -> Int
toString (Id a) =
    a
