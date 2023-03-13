module MicroScheme.Init exposing (rootFrame)

import Dict
import MicroScheme.Expr exposing (Expr(..))
import MicroScheme.Frame as Frame exposing (Frame)


rootFrame : Frame
rootFrame =
    { id = 0
    , bindings =
        Dict.fromList
            [ ( "+", Sym "+" )
            , ( "*", Sym "*" )
            ]
    }
