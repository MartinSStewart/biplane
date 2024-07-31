module Font exposing (..)

import Dict


font :
    { lineHeight : Int
    , fontSize : Int
    , base : Int
    , name : String
    , glyphs :
        Dict.Dict Char.Char { x : Int
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
    , name = "DINPro-Medium"
    , glyphs =
        Dict.fromList
            [ ( ' '
              , { x = 1012
                , y = 628
                , width = 11
                , height = 9
                , xOffset = -5
                , yOffset = 59
                , xAdvance = 12
                }
              )
            , ( '!'
              , { x = 1006
                , y = 492
                , width = 15
                , height = 44
                , xOffset = 2
                , yOffset = 12
                , xAdvance = 17
                }
              )
            , ( '"'
              , { x = 346
                , y = 702
                , width = 22
                , height = 18
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 22
                }
              )
            , ( '#'
              , { x = 239
                , y = 363
                , width = 37
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 34
                }
              )
            , ( '$'
              , { x = 215
                , y = 57
                , width = 35
                , height = 55
                , xOffset = -3
                , yOffset = 7
                , xAdvance = 30
                }
              )
            , ( '%'
              , { x = 232
                , y = 318
                , width = 44
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 42
                }
              )
            , ( '&'
              , { x = 822
                , y = 313
                , width = 40
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 37
                }
              )
            , ( '\''
              , { x = 369
                , y = 700
                , width = 13
                , height = 18
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 13
                }
              )
            , ( '('
              , { x = 930
                , y = 112
                , width = 17
                , height = 54
                , xOffset = 0
                , yOffset = 7
                , xAdvance = 16
                }
              )
            , ( ')'
              , { x = 948
                , y = 112
                , width = 17
                , height = 54
                , xOffset = -1
                , yOffset = 7
                , xAdvance = 16
                }
              )
            , ( '*'
              , { x = 962
                , y = 653
                , width = 27
                , height = 27
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 24
                }
              )
            , ( '+'
              , { x = 721
                , y = 653
                , width = 31
                , height = 31
                , xOffset = -2
                , yOffset = 23
                , xAdvance = 27
                }
              )
            , ( ','
              , { x = 161
                , y = 707
                , width = 14
                , height = 22
                , xOffset = 0
                , yOffset = 42
                , xAdvance = 14
                }
              )
            , ( '-'
              , { x = 963
                , y = 681
                , width = 23
                , height = 13
                , xOffset = -1
                , yOffset = 32
                , xAdvance = 21
                }
              )
            , ( '.'
              , { x = 780
                , y = 684
                , width = 14
                , height = 14
                , xOffset = 0
                , yOffset = 42
                , xAdvance = 14
                }
              )
            , ( '/'
              , { x = 859
                , y = 168
                , width = 28
                , height = 52
                , xOffset = -4
                , yOffset = 8
                , xAdvance = 19
                }
              )
            , ( '0'
              , { x = 676
                , y = 494
                , width = 29
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( '1'
              , { x = 965
                , y = 538
                , width = 20
                , height = 44
                , xOffset = 2
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( '2'
              , { x = 916
                , y = 493
                , width = 29
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( '3'
              , { x = 281
                , y = 498
                , width = 30
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( '4'
              , { x = 236
                , y = 453
                , width = 32
                , height = 44
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( '5'
              , { x = 586
                , y = 494
                , width = 29
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( '6'
              , { x = 826
                , y = 493
                , width = 29
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( '7'
              , { x = 312
                , y = 498
                , width = 30
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( '8'
              , { x = 343
                , y = 498
                , width = 30
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( '9'
              , { x = 496
                , y = 495
                , width = 29
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( ':'
              , { x = 947
                , y = 653
                , width = 14
                , height = 28
                , xOffset = 1
                , yOffset = 28
                , xAdvance = 15
                }
              )
            , ( ';'
              , { x = 693
                , y = 584
                , width = 14
                , height = 36
                , xOffset = 1
                , yOffset = 28
                , xAdvance = 15
                }
              )
            , ( '<'
              , { x = 621
                , y = 657
                , width = 27
                , height = 32
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 27
                }
              )
            , ( '='
              , { x = 129
                , y = 708
                , width = 31
                , height = 22
                , xOffset = -2
                , yOffset = 27
                , xAdvance = 27
                }
              )
            , ( '>'
              , { x = 649
                , y = 657
                , width = 27
                , height = 32
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 27
                }
              )
            , ( '?'
              , { x = 621
                , y = 539
                , width = 28
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 26
                }
              )
            , ( '@'
              , { x = 318
                , y = 269
                , width = 39
                , height = 45
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 37
                }
              )
            , ( 'A'
              , { x = 943
                , y = 312
                , width = 39
                , height = 44
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 31
                }
              )
            , ( 'B'
              , { x = 34
                , y = 458
                , width = 33
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 33
                }
              )
            , ( 'C'
              , { x = 385
                , y = 405
                , width = 34
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 31
                }
              )
            , ( 'D'
              , { x = 932
                , y = 403
                , width = 33
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 33
                }
              )
            , ( 'E'
              , { x = 794
                , y = 448
                , width = 31
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 30
                }
              )
            , ( 'F'
              , { x = 32
                , y = 503
                , width = 31
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 29
                }
              )
            , ( 'G'
              , { x = 966
                , y = 402
                , width = 33
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 32
                }
              )
            , ( 'H'
              , { x = 0
                , y = 458
                , width = 33
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 35
                }
              )
            , ( 'I'
              , { x = 66
                , y = 593
                , width = 14
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 15
                }
              )
            , ( 'J'
              , { x = 0
                , y = 548
                , width = 29
                , height = 44
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 25
                }
              )
            , ( 'K'
              , { x = 764
                , y = 358
                , width = 36
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 33
                }
              )
            , ( 'L'
              , { x = 826
                , y = 448
                , width = 31
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 29
                }
              )
            , ( 'M'
              , { x = 40
                , y = 368
                , width = 39
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 41
                }
              )
            , ( 'N'
              , { x = 245
                , y = 408
                , width = 34
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 36
                }
              )
            , ( 'O'
              , { x = 898
                , y = 403
                , width = 33
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 32
                }
              )
            , ( 'P'
              , { x = 500
                , y = 450
                , width = 32
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 31
                }
              )
            , ( 'Q'
              , { x = 320
                , y = 222
                , width = 35
                , height = 46
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 32
                }
              )
            , ( 'R'
              , { x = 102
                , y = 458
                , width = 33
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 33
                }
              )
            , ( 'S'
              , { x = 280
                , y = 408
                , width = 34
                , height = 44
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 30
                }
              )
            , ( 'T'
              , { x = 455
                , y = 405
                , width = 34
                , height = 44
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'U'
              , { x = 558
                , y = 404
                , width = 33
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 34
                }
              )
            , ( 'V'
              , { x = 801
                , y = 358
                , width = 36
                , height = 44
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'W'
              , { x = 786
                , y = 268
                , width = 51
                , height = 44
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 44
                }
              )
            , ( 'X'
              , { x = 429
                , y = 360
                , width = 37
                , height = 44
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 29
                }
              )
            , ( 'Y'
              , { x = 838
                , y = 358
                , width = 36
                , height = 44
                , xOffset = -5
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( 'Z'
              , { x = 467
                , y = 450
                , width = 32
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( '['
              , { x = 964
                , y = 167
                , width = 19
                , height = 52
                , xOffset = 0
                , yOffset = 8
                , xAdvance = 17
                }
              )
            , ( '\\'
              , { x = 0
                , y = 224
                , width = 27
                , height = 51
                , xOffset = -4
                , yOffset = 9
                , xAdvance = 19
                }
              )
            , ( ']'
              , { x = 50
                , y = 224
                , width = 19
                , height = 50
                , xOffset = -2
                , yOffset = 9
                , xAdvance = 17
                }
              )
            , ( '^'
              , { x = 97
                , y = 708
                , width = 31
                , height = 24
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 29
                }
              )
            , ( '_'
              , { x = 14
                , y = 735
                , width = 37
                , height = 12
                , xOffset = -4
                , yOffset = 53
                , xAdvance = 29
                }
              )
            , ( '`'
              , { x = 553
                , y = 695
                , width = 18
                , height = 16
                , xOffset = 1
                , yOffset = 10
                , xAdvance = 25
                }
              )
            , ( 'a'
              , { x = 982
                , y = 618
                , width = 29
                , height = 34
                , xOffset = -2
                , yOffset = 22
                , xAdvance = 27
                }
              )
            , ( 'b'
              , { x = 466
                , y = 495
                , width = 29
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'c'
              , { x = 265
                , y = 670
                , width = 28
                , height = 34
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 24
                }
              )
            , ( 'd'
              , { x = 210
                , y = 546
                , width = 29
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'e'
              , { x = 590
                , y = 625
                , width = 30
                , height = 34
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 27
                }
              )
            , ( 'f'
              , { x = 943
                , y = 538
                , width = 21
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 16
                }
              )
            , ( 'g'
              , { x = 505
                , y = 540
                , width = 28
                , height = 44
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 27
                }
              )
            , ( 'h'
              , { x = 679
                , y = 539
                , width = 28
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'i'
              , { x = 96
                , y = 593
                , width = 14
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 13
                }
              )
            , ( 'j'
              , { x = 872
                , y = 113
                , width = 19
                , height = 54
                , xOffset = -5
                , yOffset = 12
                , xAdvance = 13
                }
              )
            , ( 'k'
              , { x = 986
                , y = 447
                , width = 31
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( 'l'
              , { x = 986
                , y = 538
                , width = 18
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 16
                }
              )
            , ( 'm'
              , { x = 942
                , y = 583
                , width = 44
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 44
                }
              )
            , ( 'n'
              , { x = 772
                , y = 618
                , width = 29
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 28
                }
              )
            , ( 'o'
              , { x = 742
                , y = 618
                , width = 29
                , height = 34
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 27
                }
              )
            , ( 'p'
              , { x = 766
                , y = 493
                , width = 29
                , height = 44
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 28
                }
              )
            , ( 'q'
              , { x = 856
                , y = 493
                , width = 29
                , height = 44
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 28
                }
              )
            , ( 'r'
              , { x = 409
                , y = 665
                , width = 26
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 22
                }
              )
            , ( 's'
              , { x = 621
                , y = 622
                , width = 30
                , height = 34
                , xOffset = -3
                , yOffset = 22
                , xAdvance = 25
                }
              )
            , ( 't'
              , { x = 484
                , y = 585
                , width = 21
                , height = 41
                , xOffset = -2
                , yOffset = 15
                , xAdvance = 17
                }
              )
            , ( 'u'
              , { x = 294
                , y = 670
                , width = 28
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 28
                }
              )
            , ( 'v'
              , { x = 304
                , y = 632
                , width = 32
                , height = 34
                , xOffset = -4
                , yOffset = 22
                , xAdvance = 24
                }
              )
            , ( 'w'
              , { x = 896
                , y = 583
                , width = 45
                , height = 34
                , xOffset = -4
                , yOffset = 22
                , xAdvance = 37
                }
              )
            , ( 'x'
              , { x = 337
                , y = 630
                , width = 31
                , height = 34
                , xOffset = -3
                , yOffset = 22
                , xAdvance = 25
                }
              )
            , ( 'y'
              , { x = 665
                , y = 449
                , width = 32
                , height = 44
                , xOffset = -4
                , yOffset = 22
                , xAdvance = 23
                }
              )
            , ( 'z'
              , { x = 381
                , y = 665
                , width = 27
                , height = 34
                , xOffset = -2
                , yOffset = 22
                , xAdvance = 23
                }
              )
            , ( '{'
              , { x = 939
                , y = 167
                , width = 24
                , height = 52
                , xOffset = -2
                , yOffset = 8
                , xAdvance = 20
                }
              )
            , ( '|'
              , { x = 1010
                , y = 0
                , width = 13
                , height = 52
                , xOffset = 2
                , yOffset = 8
                , xAdvance = 17
                }
              )
            , ( '}'
              , { x = 888
                , y = 168
                , width = 25
                , height = 52
                , xOffset = -2
                , yOffset = 8
                , xAdvance = 20
                }
              )
            , ( '~'
              , { x = 383
                , y = 700
                , width = 33
                , height = 16
                , xOffset = -2
                , yOffset = 30
                , xAdvance = 29
                }
              )
            , ( ' '
              , { x = 1012
                , y = 618
                , width = 11
                , height = 9
                , xOffset = -5
                , yOffset = 59
                , xAdvance = 12
                }
              )
            , ( '¡'
              , { x = 19
                , y = 593
                , width = 15
                , height = 44
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 17
                }
              )
            , ( '¢'
              , { x = 650
                , y = 539
                , width = 28
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 25
                }
              )
            , ( '£'
              , { x = 170
                , y = 456
                , width = 32
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( '¤'
              , { x = 624
                , y = 584
                , width = 35
                , height = 36
                , xOffset = -1
                , yOffset = 20
                , xAdvance = 33
                }
              )
            , ( '¥'
              , { x = 875
                , y = 358
                , width = 36
                , height = 44
                , xOffset = -5
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( '¦'
              , { x = 984
                , y = 166
                , width = 13
                , height = 52
                , xOffset = 2
                , yOffset = 8
                , xAdvance = 17
                }
              )
            , ( '§'
              , { x = 709
                , y = 113
                , width = 29
                , height = 54
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( '¨'
              , { x = 709
                , y = 689
                , width = 25
                , height = 14
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 25
                }
              )
            , ( '©'
              , { x = 140
                , y = 321
                , width = 45
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 43
                }
              )
            , ( 'ª'
              , { x = 922
                , y = 653
                , width = 24
                , height = 29
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 23
                }
              )
            , ( '«'
              , { x = 521
                , y = 662
                , width = 33
                , height = 32
                , xOffset = -3
                , yOffset = 22
                , xAdvance = 30
                }
              )
            , ( '¬'
              , { x = 176
                , y = 707
                , width = 30
                , height = 20
                , xOffset = -2
                , yOffset = 31
                , xAdvance = 27
                }
              )
            , ( '­'
              , { x = 987
                , y = 681
                , width = 23
                , height = 13
                , xOffset = -1
                , yOffset = 32
                , xAdvance = 21
                }
              )
            , ( '®'
              , { x = 186
                , y = 318
                , width = 45
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 43
                }
              )
            , ( '¯'
              , { x = 52
                , y = 735
                , width = 25
                , height = 12
                , xOffset = 0
                , yOffset = 13
                , xAdvance = 25
                }
              )
            , ( '°'
              , { x = 71
                , y = 708
                , width = 25
                , height = 25
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 24
                }
              )
            , ( '±'
              , { x = 592
                , y = 584
                , width = 31
                , height = 37
                , xOffset = -2
                , yOffset = 19
                , xAdvance = 27
                }
              )
            , ( '²'
              , { x = 855
                , y = 653
                , width = 22
                , height = 30
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 18
                }
              )
            , ( '³'
              , { x = 753
                , y = 653
                , width = 22
                , height = 31
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 18
                }
              )
            , ( '´'
              , { x = 572
                , y = 694
                , width = 18
                , height = 16
                , xOffset = 6
                , yOffset = 10
                , xAdvance = 25
                }
              )
            , ( 'µ'
              , { x = 389
                , y = 543
                , width = 28
                , height = 44
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 28
                }
              )
            , ( '¶'
              , { x = 350
                , y = 113
                , width = 33
                , height = 54
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 32
                }
              )
            , ( '·'
              , { x = 750
                , y = 685
                , width = 14
                , height = 14
                , xOffset = 0
                , yOffset = 31
                , xAdvance = 14
                }
              )
            , ( '¸'
              , { x = 609
                , y = 694
                , width = 16
                , height = 16
                , xOffset = 4
                , yOffset = 50
                , xAdvance = 25
                }
              )
            , ( '¹'
              , { x = 878
                , y = 653
                , width = 17
                , height = 30
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 14
                }
              )
            , ( 'º'
              , { x = 896
                , y = 653
                , width = 25
                , height = 29
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 23
                }
              )
            , ( '»'
              , { x = 555
                , y = 661
                , width = 33
                , height = 32
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 30
                }
              )
            , ( '¼'
              , { x = 937
                , y = 267
                , width = 46
                , height = 44
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 40
                }
              )
            , ( '½'
              , { x = 0
                , y = 323
                , width = 46
                , height = 44
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 41
                }
              )
            , ( '¾'
              , { x = 47
                , y = 323
                , width = 46
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 42
                }
              )
            , ( '¿'
              , { x = 360
                , y = 543
                , width = 28
                , height = 44
                , xOffset = -2
                , yOffset = 22
                , xAdvance = 26
                }
              )
            , ( 'À'
              , { x = 138
                , y = 57
                , width = 39
                , height = 55
                , xOffset = -4
                , yOffset = 1
                , xAdvance = 31
                }
              )
            , ( 'Á'
              , { x = 98
                , y = 57
                , width = 39
                , height = 55
                , xOffset = -4
                , yOffset = 1
                , xAdvance = 31
                }
              )
            , ( 'Â'
              , { x = 114
                , y = 0
                , width = 39
                , height = 56
                , xOffset = -4
                , yOffset = 0
                , xAdvance = 31
                }
              )
            , ( 'Ã'
              , { x = 964
                , y = 57
                , width = 39
                , height = 54
                , xOffset = -4
                , yOffset = 2
                , xAdvance = 31
                }
              )
            , ( 'Ä'
              , { x = 966
                , y = 112
                , width = 39
                , height = 53
                , xOffset = -4
                , yOffset = 3
                , xAdvance = 31
                }
              )
            , ( 'Å'
              , { x = 0
                , y = 0
                , width = 39
                , height = 58
                , xOffset = -4
                , yOffset = -2
                , xAdvance = 31
                }
              )
            , ( 'Æ'
              , { x = 626
                , y = 268
                , width = 54
                , height = 44
                , xOffset = -5
                , yOffset = 12
                , xAdvance = 48
                }
              )
            , ( 'Ç'
              , { x = 72
                , y = 115
                , width = 34
                , height = 54
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 31
                }
              )
            , ( 'È'
              , { x = 762
                , y = 57
                , width = 31
                , height = 55
                , xOffset = 1
                , yOffset = 1
                , xAdvance = 30
                }
              )
            , ( 'É'
              , { x = 730
                , y = 57
                , width = 31
                , height = 55
                , xOffset = 1
                , yOffset = 1
                , xAdvance = 30
                }
              )
            , ( 'Ê'
              , { x = 837
                , y = 0
                , width = 31
                , height = 56
                , xOffset = 1
                , yOffset = 0
                , xAdvance = 30
                }
              )
            , ( 'Ë'
              , { x = 348
                , y = 168
                , width = 31
                , height = 53
                , xOffset = 1
                , yOffset = 3
                , xAdvance = 30
                }
              )
            , ( 'Ì'
              , { x = 845
                , y = 57
                , width = 19
                , height = 55
                , xOffset = -4
                , yOffset = 1
                , xAdvance = 15
                }
              )
            , ( 'Í'
              , { x = 865
                , y = 57
                , width = 18
                , height = 55
                , xOffset = 1
                , yOffset = 1
                , xAdvance = 15
                }
              )
            , ( 'Î'
              , { x = 983
                , y = 0
                , width = 26
                , height = 56
                , xOffset = -6
                , yOffset = 0
                , xAdvance = 15
                }
              )
            , ( 'Ï'
              , { x = 525
                , y = 168
                , width = 24
                , height = 53
                , xOffset = -5
                , yOffset = 3
                , xAdvance = 15
                }
              )
            , ( 'Ð'
              , { x = 467
                , y = 360
                , width = 37
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 34
                }
              )
            , ( 'Ñ'
              , { x = 142
                , y = 113
                , width = 34
                , height = 54
                , xOffset = 1
                , yOffset = 2
                , xAdvance = 36
                }
              )
            , ( 'Ò'
              , { x = 461
                , y = 57
                , width = 33
                , height = 55
                , xOffset = 0
                , yOffset = 1
                , xAdvance = 32
                }
              )
            , ( 'Ó'
              , { x = 427
                , y = 57
                , width = 33
                , height = 55
                , xOffset = 0
                , yOffset = 1
                , xAdvance = 32
                }
              )
            , ( 'Ô'
              , { x = 536
                , y = 0
                , width = 33
                , height = 56
                , xOffset = 0
                , yOffset = 0
                , xAdvance = 32
                }
              )
            , ( 'Õ'
              , { x = 282
                , y = 113
                , width = 33
                , height = 54
                , xOffset = 0
                , yOffset = 2
                , xAdvance = 32
                }
              )
            , ( 'Ö'
              , { x = 181
                , y = 168
                , width = 33
                , height = 53
                , xOffset = 0
                , yOffset = 3
                , xAdvance = 32
                }
              )
            , ( '×'
              , { x = 824
                , y = 653
                , width = 30
                , height = 30
                , xOffset = -2
                , yOffset = 23
                , xAdvance = 27
                }
              )
            , ( 'Ø'
              , { x = 70
                , y = 224
                , width = 33
                , height = 49
                , xOffset = 0
                , yOffset = 10
                , xAdvance = 33
                }
              )
            , ( 'Ù'
              , { x = 597
                , y = 57
                , width = 33
                , height = 55
                , xOffset = 0
                , yOffset = 1
                , xAdvance = 34
                }
              )
            , ( 'Ú'
              , { x = 563
                , y = 57
                , width = 33
                , height = 55
                , xOffset = 0
                , yOffset = 1
                , xAdvance = 34
                }
              )
            , ( 'Û'
              , { x = 604
                , y = 0
                , width = 33
                , height = 56
                , xOffset = 0
                , yOffset = 0
                , xAdvance = 34
                }
              )
            , ( 'Ü'
              , { x = 215
                , y = 168
                , width = 33
                , height = 53
                , xOffset = 0
                , yOffset = 3
                , xAdvance = 34
                }
              )
            , ( 'Ý'
              , { x = 178
                , y = 57
                , width = 36
                , height = 55
                , xOffset = -5
                , yOffset = 1
                , xAdvance = 27
                }
              )
            , ( 'Þ'
              , { x = 566
                , y = 449
                , width = 32
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 32
                }
              )
            , ( 'ß'
              , { x = 556
                , y = 494
                , width = 29
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'à'
              , { x = 846
                , y = 221
                , width = 29
                , height = 46
                , xOffset = -2
                , yOffset = 10
                , xAdvance = 27
                }
              )
            , ( 'á'
              , { x = 876
                , y = 221
                , width = 29
                , height = 46
                , xOffset = -2
                , yOffset = 10
                , xAdvance = 27
                }
              )
            , ( 'â'
              , { x = 906
                , y = 221
                , width = 29
                , height = 46
                , xOffset = -2
                , yOffset = 10
                , xAdvance = 27
                }
              )
            , ( 'ã'
              , { x = 706
                , y = 493
                , width = 29
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( 'ä'
              , { x = 736
                , y = 493
                , width = 29
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 26
                }
              )
            , ( 'å'
              , { x = 104
                , y = 224
                , width = 29
                , height = 49
                , xOffset = -2
                , yOffset = 7
                , xAdvance = 27
                }
              )
            , ( 'æ'
              , { x = 803
                , y = 583
                , width = 46
                , height = 34
                , xOffset = -2
                , yOffset = 22
                , xAdvance = 42
                }
              )
            , ( 'ç'
              , { x = 447
                , y = 540
                , width = 28
                , height = 44
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 24
                }
              )
            , ( 'è'
              , { x = 356
                , y = 222
                , width = 30
                , height = 46
                , xOffset = -1
                , yOffset = 10
                , xAdvance = 27
                }
              )
            , ( 'é'
              , { x = 635
                , y = 221
                , width = 30
                , height = 46
                , xOffset = -1
                , yOffset = 10
                , xAdvance = 27
                }
              )
            , ( 'ê'
              , { x = 449
                , y = 222
                , width = 30
                , height = 46
                , xOffset = -1
                , yOffset = 10
                , xAdvance = 27
                }
              )
            , ( 'ë'
              , { x = 64
                , y = 503
                , width = 30
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( 'ì'
              , { x = 299
                , y = 269
                , width = 18
                , height = 46
                , xOffset = -5
                , yOffset = 10
                , xAdvance = 13
                }
              )
            , ( 'í'
              , { x = 280
                , y = 269
                , width = 18
                , height = 46
                , xOffset = 0
                , yOffset = 10
                , xAdvance = 13
                }
              )
            , ( 'î'
              , { x = 200
                , y = 271
                , width = 26
                , height = 46
                , xOffset = -6
                , yOffset = 10
                , xAdvance = 13
                }
              )
            , ( 'ï'
              , { x = 896
                , y = 538
                , width = 24
                , height = 44
                , xOffset = -5
                , yOffset = 12
                , xAdvance = 13
                }
              )
            , ( 'ð'
              , { x = 394
                , y = 269
                , width = 29
                , height = 45
                , xOffset = -1
                , yOffset = 11
                , xAdvance = 27
                }
              )
            , ( 'ñ'
              , { x = 886
                , y = 493
                , width = 29
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'ò'
              , { x = 816
                , y = 221
                , width = 29
                , height = 46
                , xOffset = -1
                , yOffset = 10
                , xAdvance = 27
                }
              )
            , ( 'ó'
              , { x = 786
                , y = 221
                , width = 29
                , height = 46
                , xOffset = -1
                , yOffset = 10
                , xAdvance = 27
                }
              )
            , ( 'ô'
              , { x = 756
                , y = 221
                , width = 29
                , height = 46
                , xOffset = -1
                , yOffset = 10
                , xAdvance = 27
                }
              )
            , ( 'õ'
              , { x = 946
                , y = 493
                , width = 29
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( 'ö'
              , { x = 976
                , y = 493
                , width = 29
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( '÷'
              , { x = 589
                , y = 661
                , width = 31
                , height = 32
                , xOffset = -2
                , yOffset = 22
                , xAdvance = 27
                }
              )
            , ( 'ø'
              , { x = 562
                , y = 585
                , width = 29
                , height = 39
                , xOffset = -1
                , yOffset = 20
                , xAdvance = 27
                }
              )
            , ( 'ù'
              , { x = 29
                , y = 276
                , width = 28
                , height = 46
                , xOffset = 0
                , yOffset = 10
                , xAdvance = 28
                }
              )
            , ( 'ú'
              , { x = 0
                , y = 276
                , width = 28
                , height = 46
                , xOffset = 0
                , yOffset = 10
                , xAdvance = 28
                }
              )
            , ( 'û'
              , { x = 994
                , y = 219
                , width = 28
                , height = 46
                , xOffset = 0
                , yOffset = 10
                , xAdvance = 28
                }
              )
            , ( 'ü'
              , { x = 534
                , y = 540
                , width = 28
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'ý'
              , { x = 772
                , y = 0
                , width = 32
                , height = 56
                , xOffset = -4
                , yOffset = 10
                , xAdvance = 23
                }
              )
            , ( 'þ'
              , { x = 739
                , y = 113
                , width = 29
                , height = 54
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'ÿ'
              , { x = 485
                , y = 113
                , width = 32
                , height = 54
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 23
                }
              )
            , ( 'Ā'
              , { x = 646
                , y = 168
                , width = 39
                , height = 52
                , xOffset = -4
                , yOffset = 4
                , xAdvance = 31
                }
              )
            , ( 'ā'
              , { x = 172
                , y = 593
                , width = 29
                , height = 43
                , xOffset = -2
                , yOffset = 13
                , xAdvance = 26
                }
              )
            , ( 'Ă'
              , { x = 74
                , y = 0
                , width = 39
                , height = 56
                , xOffset = -4
                , yOffset = 0
                , xAdvance = 31
                }
              )
            , ( 'ă'
              , { x = 696
                , y = 221
                , width = 29
                , height = 46
                , xOffset = -2
                , yOffset = 10
                , xAdvance = 27
                }
              )
            , ( 'Ą'
              , { x = 924
                , y = 57
                , width = 39
                , height = 54
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 31
                }
              )
            , ( 'ą'
              , { x = 436
                , y = 495
                , width = 29
                , height = 44
                , xOffset = -2
                , yOffset = 22
                , xAdvance = 27
                }
              )
            , ( 'Ć'
              , { x = 357
                , y = 57
                , width = 34
                , height = 55
                , xOffset = 0
                , yOffset = 1
                , xAdvance = 31
                }
              )
            , ( 'ć'
              , { x = 965
                , y = 220
                , width = 28
                , height = 46
                , xOffset = -1
                , yOffset = 10
                , xAdvance = 24
                }
              )
            , ( 'Ĉ'
              , { x = 330
                , y = 0
                , width = 34
                , height = 56
                , xOffset = 0
                , yOffset = 0
                , xAdvance = 31
                }
              )
            , ( 'ĉ'
              , { x = 936
                , y = 220
                , width = 28
                , height = 46
                , xOffset = -1
                , yOffset = 10
                , xAdvance = 24
                }
              )
            , ( 'Ċ'
              , { x = 146
                , y = 168
                , width = 34
                , height = 53
                , xOffset = 0
                , yOffset = 3
                , xAdvance = 31
                }
              )
            , ( 'ċ'
              , { x = 563
                , y = 539
                , width = 28
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 24
                }
              )
            , ( 'Č'
              , { x = 225
                , y = 0
                , width = 34
                , height = 56
                , xOffset = 0
                , yOffset = 0
                , xAdvance = 31
                }
              )
            , ( 'č'
              , { x = 87
                , y = 274
                , width = 28
                , height = 46
                , xOffset = -1
                , yOffset = 10
                , xAdvance = 24
                }
              )
            , ( 'Ď'
              , { x = 570
                , y = 0
                , width = 33
                , height = 56
                , xOffset = 1
                , yOffset = 0
                , xAdvance = 33
                }
              )
            , ( 'ď'
              , { x = 984
                , y = 267
                , width = 39
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'Đ'
              , { x = 277
                , y = 363
                , width = 37
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 34
                }
              )
            , ( 'đ'
              , { x = 401
                , y = 450
                , width = 32
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'Ē'
              , { x = 827
                , y = 168
                , width = 31
                , height = 52
                , xOffset = 1
                , yOffset = 4
                , xAdvance = 30
                }
              )
            , ( 'ē'
              , { x = 111
                , y = 593
                , width = 30
                , height = 43
                , xOffset = -1
                , yOffset = 13
                , xAdvance = 27
                }
              )
            , ( 'Ė'
              , { x = 380
                , y = 168
                , width = 31
                , height = 53
                , xOffset = 1
                , yOffset = 3
                , xAdvance = 30
                }
              )
            , ( 'ė'
              , { x = 405
                , y = 495
                , width = 30
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( 'Ę'
              , { x = 646
                , y = 113
                , width = 31
                , height = 54
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 30
                }
              )
            , ( 'ę'
              , { x = 374
                , y = 498
                , width = 30
                , height = 44
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 27
                }
              )
            , ( 'Ě'
              , { x = 805
                , y = 0
                , width = 31
                , height = 56
                , xOffset = 1
                , yOffset = 0
                , xAdvance = 30
                }
              )
            , ( 'ě'
              , { x = 542
                , y = 222
                , width = 30
                , height = 46
                , xOffset = -1
                , yOffset = 10
                , xAdvance = 27
                }
              )
            , ( 'Ĝ'
              , { x = 468
                , y = 0
                , width = 33
                , height = 56
                , xOffset = 0
                , yOffset = 0
                , xAdvance = 32
                }
              )
            , ( 'ĝ'
              , { x = 927
                , y = 0
                , width = 28
                , height = 56
                , xOffset = -1
                , yOffset = 10
                , xAdvance = 27
                }
              )
            , ( 'Ğ'
              , { x = 400
                , y = 0
                , width = 33
                , height = 56
                , xOffset = 0
                , yOffset = 0
                , xAdvance = 32
                }
              )
            , ( 'ğ'
              , { x = 869
                , y = 0
                , width = 28
                , height = 56
                , xOffset = -1
                , yOffset = 10
                , xAdvance = 27
                }
              )
            , ( 'Ġ'
              , { x = 249
                , y = 168
                , width = 33
                , height = 53
                , xOffset = 0
                , yOffset = 3
                , xAdvance = 32
                }
              )
            , ( 'ġ'
              , { x = 769
                , y = 113
                , width = 28
                , height = 54
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( 'Ģ'
              , { x = 384
                , y = 113
                , width = 33
                , height = 54
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 32
                }
              )
            , ( 'ģ'
              , { x = 898
                , y = 0
                , width = 28
                , height = 56
                , xOffset = -1
                , yOffset = 10
                , xAdvance = 27
                }
              )
            , ( 'Ĥ'
              , { x = 502
                , y = 0
                , width = 33
                , height = 56
                , xOffset = 1
                , yOffset = 0
                , xAdvance = 35
                }
              )
            , ( 'ĥ'
              , { x = 392
                , y = 57
                , width = 34
                , height = 55
                , xOffset = -6
                , yOffset = 1
                , xAdvance = 28
                }
              )
            , ( 'Ħ'
              , { x = 407
                , y = 315
                , width = 41
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 36
                }
              )
            , ( 'ħ'
              , { x = 858
                , y = 448
                , width = 31
                , height = 44
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'Ī'
              , { x = 914
                , y = 167
                , width = 24
                , height = 52
                , xOffset = -5
                , yOffset = 4
                , xAdvance = 15
                }
              )
            , ( 'ī'
              , { x = 289
                , y = 588
                , width = 24
                , height = 43
                , xOffset = -5
                , yOffset = 13
                , xAdvance = 13
                }
              )
            , ( 'Į'
              , { x = 892
                , y = 112
                , width = 18
                , height = 54
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 15
                }
              )
            , ( 'į'
              , { x = 911
                , y = 112
                , width = 18
                , height = 54
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 13
                }
              )
            , ( 'İ'
              , { x = 1006
                , y = 112
                , width = 14
                , height = 53
                , xOffset = 1
                , yOffset = 3
                , xAdvance = 15
                }
              )
            , ( 'ı'
              , { x = 507
                , y = 662
                , width = 13
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 13
                }
              )
            , ( 'Ĵ'
              , { x = 154
                , y = 0
                , width = 35
                , height = 56
                , xOffset = -4
                , yOffset = 0
                , xAdvance = 25
                }
              )
            , ( 'ĵ'
              , { x = 956
                , y = 0
                , width = 26
                , height = 56
                , xOffset = -6
                , yOffset = 10
                , xAdvance = 13
                }
              )
            , ( 'Ķ'
              , { x = 0
                , y = 115
                , width = 36
                , height = 54
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 33
                }
              )
            , ( 'ķ'
              , { x = 518
                , y = 113
                , width = 31
                , height = 54
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( 'Ĺ'
              , { x = 698
                , y = 57
                , width = 31
                , height = 55
                , xOffset = 1
                , yOffset = 1
                , xAdvance = 29
                }
              )
            , ( 'ĺ'
              , { x = 825
                , y = 57
                , width = 19
                , height = 55
                , xOffset = 0
                , yOffset = 1
                , xAdvance = 16
                }
              )
            , ( 'Ļ'
              , { x = 614
                , y = 113
                , width = 31
                , height = 54
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 29
                }
              )
            , ( 'ļ'
              , { x = 1004
                , y = 57
                , width = 19
                , height = 54
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 16
                }
              )
            , ( 'Ľ'
              , { x = 890
                , y = 448
                , width = 31
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 29
                }
              )
            , ( 'ľ'
              , { x = 1000
                , y = 402
                , width = 23
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 16
                }
              )
            , ( 'Ł'
              , { x = 949
                , y = 357
                , width = 35
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 29
                }
              )
            , ( 'ł'
              , { x = 921
                , y = 538
                , width = 21
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 16
                }
              )
            , ( 'Ń'
              , { x = 287
                , y = 57
                , width = 34
                , height = 55
                , xOffset = 1
                , yOffset = 1
                , xAdvance = 36
                }
              )
            , ( 'ń'
              , { x = 726
                , y = 221
                , width = 29
                , height = 46
                , xOffset = 0
                , yOffset = 10
                , xAdvance = 28
                }
              )
            , ( 'Ņ'
              , { x = 247
                , y = 113
                , width = 34
                , height = 54
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 36
                }
              )
            , ( 'ņ'
              , { x = 796
                , y = 493
                , width = 29
                , height = 44
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 28
                }
              )
            , ( 'Ň'
              , { x = 260
                , y = 0
                , width = 34
                , height = 56
                , xOffset = 1
                , yOffset = 0
                , xAdvance = 36
                }
              )
            , ( 'ň'
              , { x = 666
                , y = 221
                , width = 29
                , height = 46
                , xOffset = 0
                , yOffset = 10
                , xAdvance = 28
                }
              )
            , ( 'Ō'
              , { x = 725
                , y = 168
                , width = 33
                , height = 52
                , xOffset = 0
                , yOffset = 4
                , xAdvance = 32
                }
              )
            , ( 'ō'
              , { x = 142
                , y = 593
                , width = 29
                , height = 43
                , xOffset = -1
                , yOffset = 13
                , xAdvance = 27
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
              , { x = 511
                , y = 222
                , width = 30
                , height = 46
                , xOffset = -1
                , yOffset = 10
                , xAdvance = 27
                }
              )
            , ( 'Œ'
              , { x = 734
                , y = 268
                , width = 51
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 49
                }
              )
            , ( 'œ'
              , { x = 756
                , y = 583
                , width = 46
                , height = 34
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 43
                }
              )
            , ( 'Ŕ'
              , { x = 495
                , y = 57
                , width = 33
                , height = 55
                , xOffset = 1
                , yOffset = 1
                , xAdvance = 33
                }
              )
            , ( 'ŕ'
              , { x = 227
                , y = 271
                , width = 26
                , height = 46
                , xOffset = 0
                , yOffset = 10
                , xAdvance = 22
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
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 22
                }
              )
            , ( 'Ř'
              , { x = 434
                , y = 0
                , width = 33
                , height = 56
                , xOffset = 1
                , yOffset = 0
                , xAdvance = 33
                }
              )
            , ( 'ř'
              , { x = 116
                , y = 274
                , width = 27
                , height = 46
                , xOffset = -1
                , yOffset = 10
                , xAdvance = 22
                }
              )
            , ( 'Ś'
              , { x = 322
                , y = 57
                , width = 34
                , height = 55
                , xOffset = -3
                , yOffset = 1
                , xAdvance = 30
                }
              )
            , ( 'ś'
              , { x = 418
                , y = 222
                , width = 30
                , height = 46
                , xOffset = -3
                , yOffset = 10
                , xAdvance = 25
                }
              )
            , ( 'Ŝ'
              , { x = 365
                , y = 0
                , width = 34
                , height = 56
                , xOffset = -3
                , yOffset = 0
                , xAdvance = 30
                }
              )
            , ( 'ŝ'
              , { x = 387
                , y = 222
                , width = 30
                , height = 46
                , xOffset = -3
                , yOffset = 10
                , xAdvance = 25
                }
              )
            , ( 'Ş'
              , { x = 37
                , y = 115
                , width = 34
                , height = 54
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 30
                }
              )
            , ( 'ş'
              , { x = 157
                , y = 503
                , width = 30
                , height = 44
                , xOffset = -3
                , yOffset = 22
                , xAdvance = 25
                }
              )
            , ( 'Š'
              , { x = 295
                , y = 0
                , width = 34
                , height = 56
                , xOffset = -3
                , yOffset = 0
                , xAdvance = 30
                }
              )
            , ( 'š'
              , { x = 573
                , y = 221
                , width = 30
                , height = 46
                , xOffset = -3
                , yOffset = 10
                , xAdvance = 25
                }
              )
            , ( 'Ţ'
              , { x = 107
                , y = 113
                , width = 34
                , height = 54
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'ţ'
              , { x = 28
                , y = 224
                , width = 21
                , height = 51
                , xOffset = -2
                , yOffset = 15
                , xAdvance = 17
                }
              )
            , ( 'Ť'
              , { x = 190
                , y = 0
                , width = 34
                , height = 56
                , xOffset = -3
                , yOffset = 0
                , xAdvance = 28
                }
              )
            , ( 'ť'
              , { x = 424
                , y = 269
                , width = 25
                , height = 45
                , xOffset = -2
                , yOffset = 11
                , xAdvance = 17
                }
              )
            , ( 'Ū'
              , { x = 793
                , y = 168
                , width = 33
                , height = 52
                , xOffset = 0
                , yOffset = 4
                , xAdvance = 34
                }
              )
            , ( 'ū'
              , { x = 231
                , y = 591
                , width = 28
                , height = 43
                , xOffset = 0
                , yOffset = 13
                , xAdvance = 28
                }
              )
            , ( 'Ŭ'
              , { x = 638
                , y = 0
                , width = 33
                , height = 56
                , xOffset = 0
                , yOffset = 0
                , xAdvance = 34
                }
              )
            , ( 'ŭ'
              , { x = 58
                , y = 275
                , width = 28
                , height = 46
                , xOffset = 0
                , yOffset = 10
                , xAdvance = 28
                }
              )
            , ( 'Ů'
              , { x = 40
                , y = 0
                , width = 33
                , height = 58
                , xOffset = 0
                , yOffset = -2
                , xAdvance = 34
                }
              )
            , ( 'ů'
              , { x = 134
                , y = 222
                , width = 28
                , height = 49
                , xOffset = 0
                , yOffset = 7
                , xAdvance = 28
                }
              )
            , ( 'Ű'
              , { x = 631
                , y = 57
                , width = 33
                , height = 55
                , xOffset = 0
                , yOffset = 1
                , xAdvance = 34
                }
              )
            , ( 'ű'
              , { x = 480
                , y = 222
                , width = 30
                , height = 46
                , xOffset = 0
                , yOffset = 10
                , xAdvance = 28
                }
              )
            , ( 'Ų'
              , { x = 418
                , y = 113
                , width = 33
                , height = 54
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 34
                }
              )
            , ( 'ų'
              , { x = 476
                , y = 540
                , width = 28
                , height = 44
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 28
                }
              )
            , ( 'Ÿ'
              , { x = 0
                , y = 170
                , width = 36
                , height = 53
                , xOffset = -5
                , yOffset = 3
                , xAdvance = 27
                }
              )
            , ( 'Ź'
              , { x = 665
                , y = 57
                , width = 32
                , height = 55
                , xOffset = -2
                , yOffset = 1
                , xAdvance = 28
                }
              )
            , ( 'ź'
              , { x = 172
                , y = 271
                , width = 27
                , height = 46
                , xOffset = -2
                , yOffset = 10
                , xAdvance = 23
                }
              )
            , ( 'Ż'
              , { x = 283
                , y = 168
                , width = 32
                , height = 53
                , xOffset = -2
                , yOffset = 3
                , xAdvance = 28
                }
              )
            , ( 'ż'
              , { x = 765
                , y = 538
                , width = 27
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 23
                }
              )
            , ( 'Ž'
              , { x = 706
                , y = 0
                , width = 32
                , height = 56
                , xOffset = -2
                , yOffset = 0
                , xAdvance = 28
                }
              )
            , ( 'ž'
              , { x = 144
                , y = 272
                , width = 27
                , height = 46
                , xOffset = -2
                , yOffset = 10
                , xAdvance = 23
                }
              )
            , ( 'ƒ'
              , { x = 798
                , y = 113
                , width = 27
                , height = 54
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 21
                }
              )
            , ( 'Ș'
              , { x = 177
                , y = 113
                , width = 34
                , height = 54
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 30
                }
              )
            , ( 'ș'
              , { x = 126
                , y = 503
                , width = 30
                , height = 44
                , xOffset = -3
                , yOffset = 22
                , xAdvance = 25
                }
              )
            , ( 'Ț'
              , { x = 212
                , y = 113
                , width = 34
                , height = 54
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'ț'
              , { x = 998
                , y = 166
                , width = 21
                , height = 51
                , xOffset = -2
                , yOffset = 15
                , xAdvance = 17
                }
              )
            , ( 'ȷ'
              , { x = 0
                , y = 593
                , width = 18
                , height = 44
                , xOffset = -5
                , yOffset = 22
                , xAdvance = 13
                }
              )
            , ( 'ˆ'
              , { x = 500
                , y = 697
                , width = 26
                , height = 16
                , xOffset = 0
                , yOffset = 10
                , xAdvance = 25
                }
              )
            , ( 'ˇ'
              , { x = 473
                , y = 697
                , width = 26
                , height = 16
                , xOffset = 0
                , yOffset = 10
                , xAdvance = 25
                }
              )
            , ( '˘'
              , { x = 527
                , y = 695
                , width = 25
                , height = 16
                , xOffset = 0
                , yOffset = 10
                , xAdvance = 25
                }
              )
            , ( '˙'
              , { x = 0
                , y = 735
                , width = 13
                , height = 13
                , xOffset = 6
                , yOffset = 12
                , xAdvance = 25
                }
              )
            , ( '˚'
              , { x = 207
                , y = 707
                , width = 21
                , height = 20
                , xOffset = 2
                , yOffset = 7
                , xAdvance = 25
                }
              )
            , ( '˛'
              , { x = 591
                , y = 694
                , width = 17
                , height = 16
                , xOffset = 7
                , yOffset = 50
                , xAdvance = 25
                }
              )
            , ( '˜'
              , { x = 682
                , y = 689
                , width = 26
                , height = 14
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( '˝'
              , { x = 417
                , y = 700
                , width = 27
                , height = 16
                , xOffset = 0
                , yOffset = 10
                , xAdvance = 25
                }
              )
            , ( '΄'
              , { x = 626
                , y = 690
                , width = 14
                , height = 16
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 12
                }
              )
            , ( '΅'
              , { x = 445
                , y = 697
                , width = 27
                , height = 16
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 24
                }
              )
            , ( 'Ά'
              , { x = 699
                , y = 313
                , width = 40
                , height = 44
                , xOffset = -5
                , yOffset = 12
                , xAdvance = 31
                }
              )
            , ( '·'
              , { x = 735
                , y = 685
                , width = 14
                , height = 14
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 14
                }
              )
            , ( 'Έ'
              , { x = 575
                , y = 314
                , width = 41
                , height = 44
                , xOffset = -9
                , yOffset = 12
                , xAdvance = 30
                }
              )
            , ( 'Ή'
              , { x = 277
                , y = 318
                , width = 43
                , height = 44
                , xOffset = -9
                , yOffset = 12
                , xAdvance = 35
                }
              )
            , ( 'Ί'
              , { x = 846
                , y = 538
                , width = 24
                , height = 44
                , xOffset = -9
                , yOffset = 12
                , xAdvance = 15
                }
              )
            , ( 'Ό'
              , { x = 449
                , y = 315
                , width = 41
                , height = 44
                , xOffset = -8
                , yOffset = 12
                , xAdvance = 32
                }
              )
            , ( 'Ύ'
              , { x = 491
                , y = 314
                , width = 41
                , height = 44
                , xOffset = -10
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( 'Ώ'
              , { x = 533
                , y = 314
                , width = 41
                , height = 44
                , xOffset = -8
                , yOffset = 12
                , xAdvance = 32
                }
              )
            , ( 'ΐ'
              , { x = 737
                , y = 538
                , width = 27
                , height = 44
                , xOffset = -7
                , yOffset = 12
                , xAdvance = 16
                }
              )
            , ( 'Α'
              , { x = 160
                , y = 366
                , width = 39
                , height = 44
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 31
                }
              )
            , ( 'Β'
              , { x = 864
                , y = 403
                , width = 33
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 33
                }
              )
            , ( 'Γ'
              , { x = 954
                , y = 448
                , width = 31
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'Δ'
              , { x = 863
                , y = 313
                , width = 39
                , height = 44
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 31
                }
              )
            , ( 'Ε'
              , { x = 922
                , y = 448
                , width = 31
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 30
                }
              )
            , ( 'Ζ'
              , { x = 434
                , y = 450
                , width = 32
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'Η'
              , { x = 728
                , y = 403
                , width = 33
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 35
                }
              )
            , ( 'Θ'
              , { x = 626
                , y = 404
                , width = 33
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 32
                }
              )
            , ( 'Ι'
              , { x = 51
                , y = 593
                , width = 14
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 15
                }
              )
            , ( 'Κ'
              , { x = 505
                , y = 359
                , width = 36
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 33
                }
              )
            , ( 'Λ'
              , { x = 353
                , y = 360
                , width = 37
                , height = 44
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 30
                }
              )
            , ( 'Μ'
              , { x = 120
                , y = 366
                , width = 39
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 41
                }
              )
            , ( 'Ν'
              , { x = 350
                , y = 408
                , width = 34
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 36
                }
              )
            , ( 'Ξ'
              , { x = 136
                , y = 458
                , width = 33
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 30
                }
              )
            , ( 'Ο'
              , { x = 68
                , y = 458
                , width = 33
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 32
                }
              )
            , ( 'Π'
              , { x = 302
                , y = 453
                , width = 32
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 34
                }
              )
            , ( 'Ρ'
              , { x = 368
                , y = 453
                , width = 32
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 31
                }
              )
            , ( 'Σ'
              , { x = 599
                , y = 449
                , width = 32
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'Τ'
              , { x = 35
                , y = 413
                , width = 34
                , height = 44
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'Υ'
              , { x = 542
                , y = 359
                , width = 36
                , height = 44
                , xOffset = -5
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( 'Φ'
              , { x = 364
                , y = 315
                , width = 42
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 38
                }
              )
            , ( 'Χ'
              , { x = 315
                , y = 363
                , width = 37
                , height = 44
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 29
                }
              )
            , ( 'Ψ'
              , { x = 617
                , y = 314
                , width = 40
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 35
                }
              )
            , ( 'Ω'
              , { x = 660
                , y = 404
                , width = 33
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 32
                }
              )
            , ( 'Ϊ'
              , { x = 474
                , y = 168
                , width = 25
                , height = 53
                , xOffset = -5
                , yOffset = 3
                , xAdvance = 15
                }
              )
            , ( 'Ϋ'
              , { x = 74
                , y = 170
                , width = 36
                , height = 53
                , xOffset = -5
                , yOffset = 3
                , xAdvance = 27
                }
              )
            , ( 'ά'
              , { x = 616
                , y = 494
                , width = 29
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'έ'
              , { x = 188
                , y = 501
                , width = 30
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 25
                }
              )
            , ( 'ή'
              , { x = 646
                , y = 494
                , width = 29
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'ί'
              , { x = 1005
                , y = 538
                , width = 18
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 16
                }
              )
            , ( 'ΰ'
              , { x = 526
                , y = 495
                , width = 29
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( 'α'
              , { x = 712
                , y = 618
                , width = 29
                , height = 34
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 28
                }
              )
            , ( 'β'
              , { x = 219
                , y = 501
                , width = 30
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 29
                }
              )
            , ( 'γ'
              , { x = 0
                , y = 503
                , width = 31
                , height = 44
                , xOffset = -4
                , yOffset = 22
                , xAdvance = 24
                }
              )
            , ( 'δ'
              , { x = 90
                , y = 548
                , width = 29
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( 'ε'
              , { x = 497
                , y = 627
                , width = 30
                , height = 34
                , xOffset = -2
                , yOffset = 22
                , xAdvance = 25
                }
              )
            , ( 'ζ'
              , { x = 260
                , y = 591
                , width = 28
                , height = 43
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 24
                }
              )
            , ( 'η'
              , { x = 682
                , y = 621
                , width = 29
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 28
                }
              )
            , ( 'θ'
              , { x = 150
                , y = 548
                , width = 29
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 29
                }
              )
            , ( 'ι'
              , { x = 488
                , y = 662
                , width = 18
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 16
                }
              )
            , ( 'κ'
              , { x = 433
                , y = 627
                , width = 31
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 27
                }
              )
            , ( 'λ'
              , { x = 70
                , y = 413
                , width = 34
                , height = 44
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 25
                }
              )
            , ( 'μ'
              , { x = 418
                , y = 540
                , width = 28
                , height = 44
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 28
                }
              )
            , ( 'ν'
              , { x = 271
                , y = 635
                , width = 32
                , height = 34
                , xOffset = -4
                , yOffset = 22
                , xAdvance = 24
                }
              )
            , ( 'ξ'
              , { x = 443
                , y = 168
                , width = 30
                , height = 53
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 26
                }
              )
            , ( 'ο'
              , { x = 652
                , y = 621
                , width = 29
                , height = 34
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 27
                }
              )
            , ( 'π'
              , { x = 30
                , y = 673
                , width = 29
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 30
                }
              )
            , ( 'ρ'
              , { x = 708
                , y = 538
                , width = 28
                , height = 44
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 26
                }
              )
            , ( 'ς'
              , { x = 202
                , y = 593
                , width = 28
                , height = 43
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 24
                }
              )
            , ( 'σ'
              , { x = 401
                , y = 630
                , width = 31
                , height = 34
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 28
                }
              )
            , ( 'τ'
              , { x = 462
                , y = 662
                , width = 25
                , height = 34
                , xOffset = -3
                , yOffset = 22
                , xAdvance = 20
                }
              )
            , ( 'υ'
              , { x = 60
                , y = 673
                , width = 29
                , height = 34
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 27
                }
              )
            , ( 'φ'
              , { x = 579
                , y = 359
                , width = 36
                , height = 44
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 34
                }
              )
            , ( 'χ'
              , { x = 369
                , y = 630
                , width = 31
                , height = 34
                , xOffset = -3
                , yOffset = 22
                , xAdvance = 25
                }
              )
            , ( 'ψ'
              , { x = 616
                , y = 359
                , width = 36
                , height = 44
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 34
                }
              )
            , ( 'ω'
              , { x = 126
                , y = 637
                , width = 39
                , height = 34
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 38
                }
              )
            , ( 'ϊ'
              , { x = 821
                , y = 538
                , width = 24
                , height = 44
                , xOffset = -5
                , yOffset = 12
                , xAdvance = 16
                }
              )
            , ( 'ϋ'
              , { x = 30
                , y = 548
                , width = 29
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( 'ό'
              , { x = 120
                , y = 548
                , width = 29
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( 'ύ'
              , { x = 180
                , y = 548
                , width = 29
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( 'ώ'
              , { x = 80
                , y = 368
                , width = 39
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 38
                }
              )
            , ( 'ϐ'
              , { x = 678
                , y = 113
                , width = 30
                , height = 54
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 29
                }
              )
            , ( 'Ё'
              , { x = 316
                , y = 168
                , width = 31
                , height = 53
                , xOffset = 1
                , yOffset = 3
                , xAdvance = 30
                }
              )
            , ( 'Ђ'
              , { x = 781
                , y = 313
                , width = 40
                , height = 44
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 37
                }
              )
            , ( 'Ѓ'
              , { x = 794
                , y = 57
                , width = 30
                , height = 55
                , xOffset = 1
                , yOffset = 1
                , xAdvance = 28
                }
              )
            , ( 'Є'
              , { x = 210
                , y = 408
                , width = 34
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 31
                }
              )
            , ( 'Ѕ'
              , { x = 0
                , y = 413
                , width = 34
                , height = 44
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 30
                }
              )
            , ( 'І'
              , { x = 81
                , y = 593
                , width = 14
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 15
                }
              )
            , ( 'Ї'
              , { x = 500
                , y = 168
                , width = 24
                , height = 53
                , xOffset = -5
                , yOffset = 3
                , xAdvance = 15
                }
              )
            , ( 'Ј'
              , { x = 300
                , y = 543
                , width = 29
                , height = 44
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 25
                }
              )
            , ( 'Љ'
              , { x = 513
                , y = 269
                , width = 56
                , height = 44
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 51
                }
              )
            , ( 'Њ'
              , { x = 681
                , y = 268
                , width = 52
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 51
                }
              )
            , ( 'Ћ'
              , { x = 740
                , y = 313
                , width = 40
                , height = 44
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 37
                }
              )
            , ( 'Ќ'
              , { x = 251
                , y = 57
                , width = 35
                , height = 55
                , xOffset = 1
                , yOffset = 1
                , xAdvance = 31
                }
              )
            , ( 'Ў'
              , { x = 37
                , y = 170
                , width = 36
                , height = 53
                , xOffset = -4
                , yOffset = 3
                , xAdvance = 28
                }
              )
            , ( 'Џ'
              , { x = 759
                , y = 168
                , width = 33
                , height = 52
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 35
                }
              )
            , ( 'А'
              , { x = 0
                , y = 368
                , width = 39
                , height = 44
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 31
                }
              )
            , ( 'Б'
              , { x = 762
                , y = 403
                , width = 33
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 33
                }
              )
            , ( 'В'
              , { x = 524
                , y = 404
                , width = 33
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 33
                }
              )
            , ( 'Г'
              , { x = 250
                , y = 498
                , width = 30
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'Д'
              , { x = 604
                , y = 168
                , width = 41
                , height = 52
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 35
                }
              )
            , ( 'Е'
              , { x = 698
                , y = 448
                , width = 31
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 30
                }
              )
            , ( 'Ж'
              , { x = 570
                , y = 269
                , width = 55
                , height = 44
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 46
                }
              )
            , ( 'З'
              , { x = 592
                , y = 404
                , width = 33
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 31
                }
              )
            , ( 'И'
              , { x = 140
                , y = 411
                , width = 34
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 36
                }
              )
            , ( 'Й'
              , { x = 111
                , y = 168
                , width = 34
                , height = 53
                , xOffset = 1
                , yOffset = 3
                , xAdvance = 36
                }
              )
            , ( 'К'
              , { x = 985
                , y = 357
                , width = 35
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 31
                }
              )
            , ( 'Л'
              , { x = 653
                , y = 359
                , width = 36
                , height = 44
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 34
                }
              )
            , ( 'М'
              , { x = 983
                , y = 312
                , width = 39
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 41
                }
              )
            , ( 'Н'
              , { x = 694
                , y = 403
                , width = 33
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 35
                }
              )
            , ( 'О'
              , { x = 830
                , y = 403
                , width = 33
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 32
                }
              )
            , ( 'П'
              , { x = 796
                , y = 403
                , width = 33
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 35
                }
              )
            , ( 'Р'
              , { x = 269
                , y = 453
                , width = 32
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 31
                }
              )
            , ( 'С'
              , { x = 315
                , y = 408
                , width = 34
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 31
                }
              )
            , ( 'Т'
              , { x = 175
                , y = 411
                , width = 34
                , height = 44
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'У'
              , { x = 690
                , y = 358
                , width = 36
                , height = 44
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'Ф'
              , { x = 275
                , y = 222
                , width = 44
                , height = 46
                , xOffset = -1
                , yOffset = 10
                , xAdvance = 40
                }
              )
            , ( 'Х'
              , { x = 391
                , y = 360
                , width = 37
                , height = 44
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 29
                }
              )
            , ( 'Ц'
              , { x = 686
                , y = 168
                , width = 38
                , height = 52
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 36
                }
              )
            , ( 'Ч'
              , { x = 533
                , y = 449
                , width = 32
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 32
                }
              )
            , ( 'Ш'
              , { x = 888
                , y = 268
                , width = 48
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 50
                }
              )
            , ( 'Щ'
              , { x = 550
                , y = 168
                , width = 53
                , height = 52
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 51
                }
              )
            , ( 'Ъ'
              , { x = 658
                , y = 313
                , width = 40
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 36
                }
              )
            , ( 'Ы'
              , { x = 321
                , y = 315
                , width = 42
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 44
                }
              )
            , ( 'Ь'
              , { x = 335
                , y = 453
                , width = 32
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 31
                }
              )
            , ( 'Э'
              , { x = 420
                , y = 405
                , width = 34
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 31
                }
              )
            , ( 'Ю'
              , { x = 94
                , y = 321
                , width = 45
                , height = 44
                , xOffset = 1
                , yOffset = 12
                , xAdvance = 45
                }
              )
            , ( 'Я'
              , { x = 105
                , y = 413
                , width = 34
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 33
                }
              )
            , ( 'а'
              , { x = 802
                , y = 618
                , width = 29
                , height = 34
                , xOffset = -2
                , yOffset = 22
                , xAdvance = 27
                }
              )
            , ( 'б'
              , { x = 330
                , y = 543
                , width = 29
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( 'в'
              , { x = 832
                , y = 618
                , width = 29
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 27
                }
              )
            , ( 'г'
              , { x = 436
                , y = 662
                , width = 25
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 21
                }
              )
            , ( 'д'
              , { x = 360
                , y = 588
                , width = 35
                , height = 41
                , xOffset = -4
                , yOffset = 22
                , xAdvance = 28
                }
              )
            , ( 'е'
              , { x = 862
                , y = 618
                , width = 29
                , height = 34
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 27
                }
              )
            , ( 'ж'
              , { x = 850
                , y = 583
                , width = 45
                , height = 34
                , xOffset = -4
                , yOffset = 22
                , xAdvance = 37
                }
              )
            , ( 'з'
              , { x = 892
                , y = 618
                , width = 29
                , height = 34
                , xOffset = -3
                , yOffset = 22
                , xAdvance = 24
                }
              )
            , ( 'и'
              , { x = 922
                , y = 618
                , width = 29
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 29
                }
              )
            , ( 'й'
              , { x = 270
                , y = 543
                , width = 29
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 29
                }
              )
            , ( 'к'
              , { x = 559
                , y = 626
                , width = 30
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 26
                }
              )
            , ( 'л'
              , { x = 238
                , y = 635
                , width = 32
                , height = 34
                , xOffset = -4
                , yOffset = 22
                , xAdvance = 28
                }
              )
            , ( 'м'
              , { x = 204
                , y = 637
                , width = 33
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 33
                }
              )
            , ( 'н'
              , { x = 149
                , y = 672
                , width = 28
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 28
                }
              )
            , ( 'о'
              , { x = 952
                , y = 618
                , width = 29
                , height = 34
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 27
                }
              )
            , ( 'п'
              , { x = 207
                , y = 672
                , width = 28
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 28
                }
              )
            , ( 'р'
              , { x = 240
                , y = 546
                , width = 29
                , height = 44
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 28
                }
              )
            , ( 'с'
              , { x = 178
                , y = 672
                , width = 28
                , height = 34
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 24
                }
              )
            , ( 'т'
              , { x = 0
                , y = 673
                , width = 29
                , height = 34
                , xOffset = -3
                , yOffset = 22
                , xAdvance = 22
                }
              )
            , ( 'у'
              , { x = 632
                , y = 449
                , width = 32
                , height = 44
                , xOffset = -4
                , yOffset = 22
                , xAdvance = 24
                }
              )
            , ( 'ф'
              , { x = 884
                , y = 57
                , width = 39
                , height = 54
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 35
                }
              )
            , ( 'х'
              , { x = 465
                , y = 627
                , width = 31
                , height = 34
                , xOffset = -3
                , yOffset = 22
                , xAdvance = 25
                }
              )
            , ( 'ц'
              , { x = 396
                , y = 588
                , width = 32
                , height = 41
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 29
                }
              )
            , ( 'ч'
              , { x = 323
                , y = 667
                , width = 28
                , height = 34
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 27
                }
              )
            , ( 'ш'
              , { x = 44
                , y = 638
                , width = 41
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 41
                }
              )
            , ( 'щ'
              , { x = 314
                , y = 588
                , width = 45
                , height = 41
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 42
                }
              )
            , ( 'ъ'
              , { x = 987
                , y = 583
                , width = 35
                , height = 34
                , xOffset = -4
                , yOffset = 22
                , xAdvance = 29
                }
              )
            , ( 'ы'
              , { x = 166
                , y = 637
                , width = 37
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 37
                }
              )
            , ( 'ь'
              , { x = 120
                , y = 673
                , width = 28
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 26
                }
              )
            , ( 'э'
              , { x = 236
                , y = 672
                , width = 28
                , height = 34
                , xOffset = -3
                , yOffset = 22
                , xAdvance = 24
                }
              )
            , ( 'ю'
              , { x = 86
                , y = 638
                , width = 39
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 38
                }
              )
            , ( 'я'
              , { x = 90
                , y = 673
                , width = 29
                , height = 34
                , xOffset = -3
                , yOffset = 22
                , xAdvance = 27
                }
              )
            , ( 'ё'
              , { x = 60
                , y = 548
                , width = 29
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( 'ђ'
              , { x = 582
                , y = 113
                , width = 31
                , height = 54
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'ѓ'
              , { x = 254
                , y = 271
                , width = 25
                , height = 46
                , xOffset = 0
                , yOffset = 10
                , xAdvance = 21
                }
              )
            , ( 'є'
              , { x = 352
                , y = 665
                , width = 28
                , height = 34
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 24
                }
              )
            , ( 'ѕ'
              , { x = 528
                , y = 626
                , width = 30
                , height = 34
                , xOffset = -3
                , yOffset = 22
                , xAdvance = 25
                }
              )
            , ( 'і'
              , { x = 35
                , y = 593
                , width = 15
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 13
                }
              )
            , ( 'ї'
              , { x = 871
                , y = 538
                , width = 24
                , height = 44
                , xOffset = -5
                , yOffset = 12
                , xAdvance = 13
                }
              )
            , ( 'ј'
              , { x = 852
                , y = 113
                , width = 19
                , height = 54
                , xOffset = -5
                , yOffset = 12
                , xAdvance = 13
                }
              )
            , ( 'љ'
              , { x = 708
                , y = 583
                , width = 47
                , height = 34
                , xOffset = -4
                , yOffset = 22
                , xAdvance = 41
                }
              )
            , ( 'њ'
              , { x = 0
                , y = 638
                , width = 43
                , height = 34
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 41
                }
              )
            , ( 'ћ'
              , { x = 730
                , y = 448
                , width = 31
                , height = 44
                , xOffset = -3
                , yOffset = 12
                , xAdvance = 28
                }
              )
            , ( 'ќ'
              , { x = 604
                , y = 221
                , width = 30
                , height = 46
                , xOffset = 0
                , yOffset = 10
                , xAdvance = 26
                }
              )
            , ( 'ў'
              , { x = 452
                , y = 113
                , width = 32
                , height = 54
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 24
                }
              )
            , ( 'џ'
              , { x = 429
                , y = 585
                , width = 28
                , height = 41
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 28
                }
              )
            , ( 'Ґ'
              , { x = 412
                , y = 168
                , width = 30
                , height = 53
                , xOffset = 1
                , yOffset = 3
                , xAdvance = 28
                }
              )
            , ( 'ґ'
              , { x = 458
                , y = 585
                , width = 25
                , height = 41
                , xOffset = 0
                , yOffset = 15
                , xAdvance = 21
                }
              )
            , ( '–'
              , { x = 899
                , y = 683
                , width = 31
                , height = 13
                , xOffset = -2
                , yOffset = 32
                , xAdvance = 27
                }
              )
            , ( '—'
              , { x = 795
                , y = 684
                , width = 51
                , height = 13
                , xOffset = -1
                , yOffset = 32
                , xAdvance = 49
                }
              )
            , ( '―'
              , { x = 847
                , y = 684
                , width = 51
                , height = 13
                , xOffset = -1
                , yOffset = 32
                , xAdvance = 49
                }
              )
            , ( '‘'
              , { x = 301
                , y = 705
                , width = 14
                , height = 19
                , xOffset = 0
                , yOffset = 7
                , xAdvance = 13
                }
              )
            , ( '’'
              , { x = 316
                , y = 705
                , width = 14
                , height = 19
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 13
                }
              )
            , ( '‚'
              , { x = 331
                , y = 702
                , width = 14
                , height = 19
                , xOffset = 0
                , yOffset = 42
                , xAdvance = 13
                }
              )
            , ( '“'
              , { x = 277
                , y = 705
                , width = 23
                , height = 19
                , xOffset = 0
                , yOffset = 7
                , xAdvance = 23
                }
              )
            , ( '”'
              , { x = 253
                , y = 707
                , width = 23
                , height = 19
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 23
                }
              )
            , ( '„'
              , { x = 229
                , y = 707
                , width = 23
                , height = 19
                , xOffset = 0
                , yOffset = 42
                , xAdvance = 23
                }
              )
            , ( '†'
              , { x = 762
                , y = 448
                , width = 31
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 30
                }
              )
            , ( '‡'
              , { x = 550
                , y = 113
                , width = 31
                , height = 54
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 30
                }
              )
            , ( '•'
              , { x = 45
                , y = 708
                , width = 25
                , height = 26
                , xOffset = 0
                , yOffset = 22
                , xAdvance = 26
                }
              )
            , ( '…'
              , { x = 641
                , y = 690
                , width = 40
                , height = 14
                , xOffset = 0
                , yOffset = 42
                , xAdvance = 40
                }
              )
            , ( '‰'
              , { x = 450
                , y = 269
                , width = 62
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 60
                }
              )
            , ( '‹'
              , { x = 677
                , y = 656
                , width = 21
                , height = 32
                , xOffset = -3
                , yOffset = 22
                , xAdvance = 17
                }
              )
            , ( '›'
              , { x = 699
                , y = 656
                , width = 21
                , height = 32
                , xOffset = -1
                , yOffset = 22
                , xAdvance = 17
                }
              )
            , ( '⁄'
              , { x = 95
                , y = 503
                , width = 30
                , height = 44
                , xOffset = -10
                , yOffset = 12
                , xAdvance = 10
                }
              )
            , ( '€'
              , { x = 200
                , y = 363
                , width = 38
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 34
                }
              )
            , ( '№'
              , { x = 838
                , y = 268
                , width = 49
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 48
                }
              )
            , ( '™'
              , { x = 776
                , y = 653
                , width = 47
                , height = 30
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 44
                }
              )
            , ( 'Ω'
              , { x = 490
                , y = 405
                , width = 33
                , height = 44
                , xOffset = 0
                , yOffset = 12
                , xAdvance = 32
                }
              )
            , ( '←'
              , { x = 163
                , y = 222
                , width = 55
                , height = 48
                , xOffset = -2
                , yOffset = 14
                , xAdvance = 51
                }
              )
            , ( '↑'
              , { x = 0
                , y = 59
                , width = 48
                , height = 55
                , xOffset = 2
                , yOffset = 11
                , xAdvance = 51
                }
              )
            , ( '→'
              , { x = 219
                , y = 222
                , width = 55
                , height = 48
                , xOffset = -2
                , yOffset = 14
                , xAdvance = 51
                }
              )
            , ( '↓'
              , { x = 49
                , y = 59
                , width = 48
                , height = 55
                , xOffset = 2
                , yOffset = 11
                , xAdvance = 51
                }
              )
            , ( '∂'
              , { x = 592
                , y = 539
                , width = 28
                , height = 44
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 27
                }
              )
            , ( '∆'
              , { x = 903
                , y = 313
                , width = 39
                , height = 44
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 31
                }
              )
            , ( '∏'
              , { x = 672
                , y = 0
                , width = 33
                , height = 56
                , xOffset = 1
                , yOffset = 10
                , xAdvance = 35
                }
              )
            , ( '∑'
              , { x = 739
                , y = 0
                , width = 32
                , height = 56
                , xOffset = -2
                , yOffset = 10
                , xAdvance = 28
                }
              )
            , ( '−'
              , { x = 931
                , y = 683
                , width = 31
                , height = 13
                , xOffset = -2
                , yOffset = 32
                , xAdvance = 27
                }
              )
            , ( '∙'
              , { x = 765
                , y = 685
                , width = 14
                , height = 14
                , xOffset = 0
                , yOffset = 31
                , xAdvance = 14
                }
              )
            , ( '√'
              , { x = 727
                , y = 358
                , width = 36
                , height = 44
                , xOffset = -4
                , yOffset = 12
                , xAdvance = 29
                }
              )
            , ( '∞'
              , { x = 0
                , y = 708
                , width = 44
                , height = 26
                , xOffset = -1
                , yOffset = 25
                , xAdvance = 42
                }
              )
            , ( '∫'
              , { x = 826
                , y = 113
                , width = 25
                , height = 54
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 22
                }
              )
            , ( '≈'
              , { x = 990
                , y = 653
                , width = 33
                , height = 26
                , xOffset = -2
                , yOffset = 25
                , xAdvance = 29
                }
              )
            , ( '≠'
              , { x = 660
                , y = 584
                , width = 32
                , height = 36
                , xOffset = -2
                , yOffset = 20
                , xAdvance = 29
                }
              )
            , ( '≤'
              , { x = 534
                , y = 585
                , width = 27
                , height = 40
                , xOffset = 0
                , yOffset = 18
                , xAdvance = 27
                }
              )
            , ( '≥'
              , { x = 506
                , y = 585
                , width = 27
                , height = 40
                , xOffset = 0
                , yOffset = 18
                , xAdvance = 27
                }
              )
            , ( '◊'
              , { x = 358
                , y = 269
                , width = 35
                , height = 45
                , xOffset = -1
                , yOffset = 12
                , xAdvance = 32
                }
              )
            , ( 'ﬁ'
              , { x = 203
                , y = 456
                , width = 32
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 29
                }
              )
            , ( 'ﬂ'
              , { x = 912
                , y = 358
                , width = 36
                , height = 44
                , xOffset = -2
                , yOffset = 12
                , xAdvance = 31
                }
              )
            ]
    }