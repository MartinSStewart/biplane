module Generate exposing (main)

{-| -}

import Base64
import Bytes.Decode
import Bytes.Encode
import Dict
import Elm
import Elm.Annotation
import FntData
import Font2 exposing (Font)
import Gen.CodeGen.Generate as Generate


main : Program () () ()
main =
    Generate.run file


file : List Elm.File
file =
    case
        Base64.toBytes FntData.data
            |> Maybe.withDefault (Bytes.Encode.sequence [] |> Bytes.Encode.encode)
            |> Bytes.Decode.decode Font2.decode
    of
        Just font ->
            [ Elm.file
                [ "Font" ]
                [ Elm.declaration
                    "font"
                    (Elm.record
                        [ ( "lineHeight", Elm.int font.lineHeight )
                        , ( "fontSize", Elm.int font.fontSize )
                        , ( "base", Elm.int font.base )
                        , ( "name", Elm.string font.name )
                        , ( "glyphs"
                          , Elm.apply
                                (Elm.value
                                    { importFrom = [ "Dict" ]
                                    , name = "fromList"
                                    , annotation =
                                        Just
                                            (Elm.Annotation.function
                                                [ Elm.Annotation.list
                                                    (Elm.Annotation.tuple
                                                        (Elm.Annotation.var "k")
                                                        (Elm.Annotation.var "v")
                                                    )
                                                ]
                                                (Elm.Annotation.namedWith
                                                    [ "Dict" ]
                                                    "Dict"
                                                    [ Elm.Annotation.var "k"
                                                    , Elm.Annotation.var "v"
                                                    ]
                                                )
                                            )
                                    }
                                )
                                [ Dict.toList font.glyphs
                                    |> List.map
                                        (\( char, glyph ) ->
                                            Elm.tuple
                                                (Elm.char char)
                                                (Elm.record
                                                    [ ( "x", Elm.int glyph.x )
                                                    , ( "y", Elm.int glyph.y )
                                                    , ( "width", Elm.int glyph.width )
                                                    , ( "height", Elm.int glyph.height )
                                                    , ( "xOffset", Elm.int glyph.xOffset )
                                                    , ( "yOffset", Elm.int glyph.yOffset )
                                                    , ( "xAdvance", Elm.int glyph.xAdvance )
                                                    ]
                                                )
                                        )
                                    |> Elm.list
                                ]
                          )
                        ]
                    )
                ]
            ]

        Nothing ->
            []
