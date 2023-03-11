module MicroScheme.Examples exposing (..)

import MicroScheme.Expr exposing (Expr(..))



-- EXAMPLES


z =
    Z 1


pii =
    F 3.1416


plus =
    Sym "+"


times =
    Sym "*"


plusExpr =
    L [ plus, Z 1, Z 2, Z 3 ]


timesExpr =
    L [ times, Z 1, Z 2, Z 3, Z 4 ]


arithExpr =
    L [ times, L [ plus, Z 1, Z 2 ], L [ plus, Z 3, Z 4 ] ]
