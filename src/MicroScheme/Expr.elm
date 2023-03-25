module MicroScheme.Expr exposing (Expr(..), bar, foo, foo2)


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
    L [ Sym "apply", Sym "+", L [ Sym "map", Lambda (L [ Str "x" ]) (L [ Sym "*", Str "x", Str "x" ]), L [ Sym "list", Z 1, Z 2, Z 3, Z 4 ] ] ]


foo2 =
    L (Sym "+" :: bar)


bar : List Expr
bar =
    [ Sym "map", Lambda (L [ Str "x" ]) (L [ Sym "*", Str "x", Str "x" ]), L [ Z 1, Z 2, Z 3, Z 4 ] ]
