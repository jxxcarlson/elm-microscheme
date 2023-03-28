module MicroScheme.Init exposing (rootFrame)

import Dict
import MicroScheme.Expr exposing (Expr(..))
import MicroScheme.Frame exposing (Frame)


symbolStrings : List String
symbolStrings =
    [ "+"
    , "*"
    , "/"
    , "-"
    , "="
    , "<"
    , ">"
    , "<="
    , ">="
    , "roundTo"
    , "remainder"
    , "quote"
    , "cons"
    , "list"
    , "car"
    , "cdr"
   , "help"
    , "map"
    , "debug"
    , "null?"
    , "atom?"
    , "apply"
    , "equal?"
    , "load"

    -- , "eval"
    ]


symbols : List ( String, Expr )
symbols =
    List.map (\s -> ( s, Sym s )) symbolStrings


rootFrame : Frame
rootFrame =
    { id = 0
    , bindings = Dict.fromList symbols
    }
