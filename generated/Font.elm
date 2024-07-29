module Font exposing (..)

import Dict


font :
    { lineHeight : Int
    , fontSize : Int
    , base : Int
    , name : String
    , glyphs :
        Dict.Dict
            Char.Char
            { x : Int
            , y : Int
            , width : Int
            , height : Int
            , xOffset : Int
            , yOffset : Int
            , xAdvance : Int
            }
    }
font =
    { lineHeight = 64
    , fontSize = 64
    , base = 52
    , name = "\u{0001}\u{0004}DINPro-Medium"
    , glyphs =
        Dict.fromList
            [ ( '\u{0000}'
              , { x = 49135
                , y = 189
                , width = 36
                , height = 53
                , xOffset = -16401
                , yOffset = -4163
                , xAdvance = -16961
                }
              )
            , ( '\u{000E}'
              , { x = 22
                , y = 14
                , width = 3840
                , height = 49135
                , xOffset = 957
                , yOffset = 0
                , xAdvance = 575
                }
              )
            , ( ' '
              , { x = 49135
                , y = 957
                , width = 628
                , height = 11
                , xOffset = 9
                , yOffset = -16401
                , xAdvance = -4163
                }
              )
            , ( ','
              , { x = 12
                , y = 49
                , width = 3840
                , height = 339
                , xOffset = 0
                , yOffset = -16401
                , xAdvance = 701
                }
              )
            , ( '.'
              , { x = 10
                , y = 28
                , width = 3840
                , height = 332
                , xOffset = 0
                , yOffset = -16401
                , xAdvance = 701
                }
              )
            , ( '0'
              , { x = 49135
                , y = 701
                , width = 49135
                , height = 445
                , xOffset = 29
                , yOffset = 44
                , xAdvance = -16401
                }
              )
            , ( '1'
              , { x = 7
                , y = 28
                , width = 3840
                , height = 368
                , xOffset = 0
                , yOffset = 631
                , xAdvance = 57
                }
              )
            , ( '6'
              , { x = 12
                , y = 29
                , width = 3840
                , height = 1025
                , xOffset = 0
                , yOffset = 316
                , xAdvance = -16401
                }
              )
            , ( '7'
              , { x = 1
                , y = 34
                , width = 3840
                , height = 369
                , xOffset = 0
                , yOffset = -16401
                , xAdvance = 445
                }
              )
            , ( '8'
              , { x = 0
                , y = 31
                , width = 3840
                , height = 269
                , xOffset = 0
                , yOffset = 87
                , xAdvance = 274
                }
              )
            , ( '>'
              , { x = 49135
                , y = 701
                , width = 49135
                , height = 701
                , xOffset = 27
                , yOffset = 32
                , xAdvance = 0
                }
              )
            , ( 'C'
              , { x = 49135
                , y = 445
                , width = 49135
                , height = 445
                , xOffset = 34
                , yOffset = 44
                , xAdvance = 0
                }
              )
            , ( 'R'
              , { x = 102
                , y = 49135
                , width = 445
                , height = 33
                , xOffset = 44
                , yOffset = 1
                , xAdvance = 12
                }
              )
            , ( '^'
              , { x = 97
                , y = 49135
                , width = 701
                , height = 31
                , xOffset = 24
                , yOffset = -16401
                , xAdvance = -4163
                }
              )
            , ( 'b'
              , { x = 49135
                , y = 445
                , width = 49135
                , height = 445
                , xOffset = 29
                , yOffset = 44
                , xAdvance = 0
                }
              )
            , ( 'f'
              , { x = 49135
                , y = 957
                , width = 538
                , height = 21
                , xOffset = 44
                , yOffset = -16401
                , xAdvance = -4163
                }
              )
            , ( 'z'
              , { x = 381
                , y = 49135
                , width = 701
                , height = 27
                , xOffset = 34
                , yOffset = -16401
                , xAdvance = -4163
                }
              )
            , ( '½'
              , { x = 49135
                , y = 957
                , width = 49135
                , height = 189
                , xOffset = 28
                , yOffset = 46
                , xAdvance = 0
                }
              )
            , ( 'Ċ'
              , { x = 49135
                , y = 189
                , width = 49135
                , height = 189
                , xOffset = 34
                , yOffset = 53
                , xAdvance = 0
                }
              )
            , ( 'Đ'
              , { x = 277
                , y = 363
                , width = 37
                , height = 44
                , xOffset = -16401
                , yOffset = -4163
                , xAdvance = -16961
                }
              )
            , ( 'ė'
              , { x = 49135
                , y = 445
                , width = 49135
                , height = 445
                , xOffset = 30
                , yOffset = 44
                , xAdvance = -16401
                }
              )
            , ( 'ġ'
              , { x = 769
                , y = 113
                , width = 28
                , height = 54
                , xOffset = -16401
                , yOffset = -4163
                , xAdvance = -16961
                }
              )
            , ( 'Ħ'
              , { x = 49135
                , y = 445
                , width = 315
                , height = 41
                , xOffset = 44
                , yOffset = -16401
                , xAdvance = -4163
                }
              )
            , ( 'ī'
              , { x = 289
                , y = 588
                , width = 24
                , height = 43
                , xOffset = -16401
                , yOffset = -4163
                , xAdvance = -16961
                }
              )
            , ( 'Ĵ'
              , { x = 49135
                , y = 189
                , width = 0
                , height = 35
                , xOffset = 56
                , yOffset = -16401
                , xAdvance = -4163
                }
              )
            , ( 'Ľ'
              , { x = 890
                , y = 49135
                , width = 445
                , height = 31
                , xOffset = 44
                , yOffset = 1
                , xAdvance = 12
                }
              )
            , ( 'Ő'
              , { x = 529
                , y = 57
                , width = 33
                , height = 55
                , xOffset = 0
                , yOffset = 1
                , xAdvance = 32
                }
              )
            , ( 'ő'
              , { x = 49135
                , y = 445
                , width = 49135
                , height = 189
                , xOffset = 30
                , yOffset = 46
                , xAdvance = -16401
                }
              )
            , ( 'Ŗ'
              , { x = 316
                , y = 113
                , width = 33
                , height = 54
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 33
                }
              )
            , ( 'ŗ'
              , { x = 793
                , y = 538
                , width = 27
                , height = 44
                , xOffset = -16401
                , yOffset = -4163
                , xAdvance = -16961
                }
              )
            , ( 'ţ'
              , { x = 28
                , y = 49135
                , width = 189
                , height = 21
                , xOffset = 51
                , yOffset = -16401
                , xAdvance = -4163
                }
              )
            , ( 'ū'
              , { x = 49135
                , y = 189
                , width = 591
                , height = 28
                , xOffset = 43
                , yOffset = 0
                , xAdvance = 13
                }
              )
            , ( '̥'
              , { x = 31
                , y = 56
                , width = 1
                , height = 0
                , xOffset = 30
                , yOffset = 3840
                , xAdvance = 283
                }
              )
            , ( 'ν'
              , { x = 49135
                , y = 445
                , width = 49135
                , height = 701
                , xOffset = 18
                , yOffset = 34
                , xAdvance = 0
                }
              )
            , ( 'Ѕ'
              , { x = 0
                , y = 49135
                , width = 445
                , height = 34
                , xOffset = 44
                , yOffset = -16401
                , xAdvance = -4163
                }
              )
            , ( 'Й'
              , { x = 111
                , y = 49135
                , width = 189
                , height = 34
                , xOffset = 53
                , yOffset = 1
                , xAdvance = 3
                }
              )
            , ( '𐀤'
              , { x = 28
                , y = 15
                , width = 3840
                , height = 60
                , xOffset = 0
                , yOffset = 621
                , xAdvance = -16401
                }
              )
            , ( '𐀬'
              , { x = 12
                , y = 33
                , width = 3840
                , height = 1042
                , xOffset = 0
                , yOffset = 524
                , xAdvance = -16401
                }
              )
            , ( '𐀶'
              , { x = 12
                , y = 30
                , width = 3840
                , height = 281
                , xOffset = 0
                , yOffset = 374
                , xAdvance = -16401
                }
              )
            , ( '𐀷'
              , { x = 1
                , y = 15
                , width = 3840
                , height = 49135
                , xOffset = 189
                , yOffset = 0
                , xAdvance = -16401
                }
              )
            , ( '\u{1BDBF}'
              , { x = 27
                , y = 3840
                , width = 49135
                , height = 189
                , xOffset = 0
                , yOffset = 566
                , xAdvance = -16401
                }
              )
            , ( '𠀬'
              , { x = 12
                , y = 27
                , width = 3840
                , height = 50
                , xOffset = 0
                , yOffset = -16401
                , xAdvance = 957
                }
              )
            , ( '\u{80000}'
              , { x = 17
                , y = 3840
                , width = 92
                , height = 0
                , xOffset = 0
                , yOffset = -16401
                , xAdvance = 189
                }
              )
            , ( '\u{9000B}'
              , { x = 49135
                , y = 61373
                , width = 48575
                , height = 59
                , xOffset = 12
                , yOffset = 3840
                , xAdvance = -16401
                }
              )
            , ( '\u{A0000}'
              , { x = 25
                , y = 3840
                , width = 49135
                , height = 701
                , xOffset = 0
                , yOffset = 527
                , xAdvance = -16401
                }
              )
            , ( '\u{ABDBF}'
              , { x = 27
                , y = 3840
                , width = 338
                , height = 0
                , xOffset = -16401
                , yOffset = 701
                , xAdvance = 268
                }
              )
            , ( '\u{C0000}'
              , { x = 32
                , y = 3840
                , width = 49135
                , height = 957
                , xOffset = 0
                , yOffset = 51
                , xAdvance = 593
                }
              )
            , ( '\u{C0001}'
              , { x = 31
                , y = 3840
                , width = 49135
                , height = 957
                , xOffset = 0
                , yOffset = 599
                , xAdvance = -16401
                }
              )
            , ( '\u{C000C}'
              , { x = 3840
                , y = 49135
                , width = 957
                , height = 0
                , xOffset = -16401
                , yOffset = 445
                , xAdvance = -16401
                }
              )
            , ( '\u{C003B}'
              , { x = 3840
                , y = 33
                , width = 0
                , height = 49135
                , xOffset = 957
                , yOffset = -16401
                , xAdvance = 445
                }
              )
            , ( '\u{CBDBF}'
              , { x = 27
                , y = 3840
                , width = 49135
                , height = 957
                , xOffset = 0
                , yOffset = -16401
                , xAdvance = 701
                }
              )
            , ( '\u{D000A}'
              , { x = 3840
                , y = 49135
                , width = 189
                , height = 0
                , xOffset = -16401
                , yOffset = 189
                , xAdvance = 271
                }
              )
            , ( '\u{D00BD}'
              , { x = 52
                , y = 2
                , width = 8
                , height = 17
                , xOffset = 3840
                , yOffset = -16401
                , xAdvance = 189
                }
              )
            , ( '\u{E001A}'
              , { x = 0
                , y = 12
                , width = 27
                , height = 3840
                , xOffset = -16401
                , yOffset = 701
                , xAdvance = 0
                }
              )
            , ( '\u{E0251}'
              , { x = 44
                , y = 0
                , width = 12
                , height = 13
                , xOffset = 3840
                , yOffset = 106
                , xAdvance = 0
                }
              )
            , ( '\u{E02BD}'
              , { x = 14
                , y = 0
                , width = 42
                , height = 14
                , xOffset = 3840
                , yOffset = 47
                , xAdvance = 0
                }
              )
            , ( '\u{F0003}'
              , { x = 3840
                , y = 49135
                , width = 189
                , height = 0
                , xOffset = -16401
                , yOffset = 445
                , xAdvance = 360
                }
              )
            , ( '\u{F000C}'
              , { x = 3840
                , y = 1031
                , width = 0
                , height = 49135
                , xOffset = 445
                , yOffset = -16401
                , xAdvance = 189
                }
              )
            , ( '\u{10000C}'
              , { x = 3840
                , y = 321
                , width = 0
                , height = 49135
                , xOffset = 957
                , yOffset = 357
                , xAdvance = 35
                }
              )
            , ( '\u{100019}'
              , { x = 0
                , y = 10
                , width = 25
                , height = 3840
                , xOffset = -16401
                , yOffset = 701
                , xAdvance = 0
                }
              )
            , ( '\u{10001B}'
              , { x = 49135
                , y = 61373
                , width = 48575
                , height = 12
                , xOffset = 24
                , yOffset = 3840
                , xAdvance = -16401
                }
              )
            , ( '�'
              , { x = 445
                , y = 33
                , width = 44
                , height = 0
                , xOffset = 12
                , yOffset = 32
                , xAdvance = 3840
                }
              )
            ]
    }
