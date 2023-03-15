module MicroScheme.Init exposing (rootFrame)

import Dict
import MicroScheme.Expr exposing (Expr(..))
import MicroScheme.Frame as Frame exposing (Frame)


symbolStrings =
    [ "+"
    , "*"
    , "="
    , "<"
    , ">"
    , "<="
    , ">="
    , "roundTo"
    , "remainder"
    , "lookup"
    , "quote"
    , "cons"
    , "list"
    , "car"
    , "cdr"
    , "map"
    ]


symbols =
    List.map (\s -> ( s, Sym s )) symbolStrings


rootFrame : Frame
rootFrame =
    { id = 0
    , bindings = Dict.fromList symbols
    }
