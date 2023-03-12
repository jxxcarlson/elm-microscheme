module MicroScheme.Init exposing (symbolTable)

import Dict
import MicroScheme.Expr exposing (Expr(..))
import MicroScheme.Frame as Frame exposing (Frame)


symbolTable : Frame
symbolTable =
    Dict.fromList
        [ ( "+", Sym "+" )
        , ( "*", Sym "*" )
        ]
