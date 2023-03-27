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
    , "lookup"
    , "env"
    , "quote"
    , "cons"
    , "list"
    , "car"
    , "cdr"
    , "map"
    , "debug"
    , "null?"
    , "atom?"
    , "apply"
    , "equal?"

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
