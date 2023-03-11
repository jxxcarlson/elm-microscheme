module MicroScheme.Expr exposing (Expr(..))


type Expr
    = Z Int
    | F Float
    | Str String
    | Sym String
    | L (List Expr)


type SpecialForm
    = Define
    | Display
    | If
