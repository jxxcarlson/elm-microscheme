module MicroScheme.Expr exposing (Expr(..), SpecialForm(..))


type Expr
    = Z Int
    | F Float
    | B Bool
    | Str String
    | Sym String
    | L (List Expr)
    | SF SpecialForm


type SpecialForm
    = Define
    | Lambda
    | Display
    | If
