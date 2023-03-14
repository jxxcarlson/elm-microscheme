module MicroScheme.Utility exposing (display)

import MicroScheme.Expr exposing (Expr(..))


display : Expr -> String
display expr =
    case expr of
        Z n ->
            String.fromInt n

        F x ->
            String.fromFloat x

        B b ->
            case b of
                True ->
                    "True"

                False ->
                    "False"

        Str s ->
            s

        Sym s ->
            s

        u ->
            "Unprocessable expression"
