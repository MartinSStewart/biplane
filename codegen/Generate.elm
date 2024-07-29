module Generate exposing (main)

{-| -}

import Bytes exposing (Bytes)
import Bytes.Decode
import Bytes.Encode
import Dict
import Elm
import Elm.Annotation
import Font2 exposing (Font)
import Gen.CodeGen.Generate as Generate
import Http


type Msg
    = GotFnt (Result Http.Error Font)


main : Program () () Msg
main =
    Platform.worker
        { init =
            \_ ->
                ( ()
                , Http.get
                    { url = "https://github.com/MartinSStewart/biplane/blob/normal-clouds/public/dinProMedium.fnt"
                    , expect = Http.expectBytes GotFnt Font2.decode
                    }
                )
        , update =
            \msg model ->
                case msg of
                    GotFnt (Ok font) ->
                        ( model, Generate.onSuccessSend (file font) )

                    GotFnt (Err _) ->
                        ( model
                        , Generate.onFailureSend [ { title = "Couldn't load .fnt file", description = "" } ]
                        )
        , subscriptions = \_ -> Sub.none
        }


file : Font -> List Elm.File
file font =
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
