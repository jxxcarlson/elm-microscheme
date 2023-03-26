module MicroScheme.Expr exposing (Expr(..))


type Expr
    = Z Int
    | F Float
    | B Bool
    | Str String
    | Sym String
    | L (List Expr)
    | Pair Expr Expr
    | Lambda Expr Expr
    | Define Expr Expr
    | If Expr Expr Expr
    | Display (List Expr)
    | Quote Expr


foo : Expr
foo =
    L [ Sym "cons", Z 2, L [ Sym "+", Z 1, Z 2, Z 3 ] ]
