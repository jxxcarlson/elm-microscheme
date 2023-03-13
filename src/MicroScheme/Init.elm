module MicroScheme.Init exposing (symbolTable)

import Dict
import MicroScheme.Expr exposing (Expr(..))
import MicroScheme.Frame as Frame exposing (Frame)


symbolTable : Frame
symbolTable =
    { id = 0
    , bindings =
        Dict.fromList
            [ ( "+", Sym "+" )
            , ( "*", Sym "*" )
            ]
    }
