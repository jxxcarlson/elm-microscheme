module MicroScheme.Utility exposing (display)

import MicroScheme.Expr exposing (Expr(..))


display : Expr -> String
display expr =
    case expr of
        L exprList ->
            "(" ++ (List.map display exprList |> String.join " ") ++ ")"

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

        Pair a b ->
            "(" ++ display a ++ " . " ++ display b ++ ")"

        Display expr_ ->
            Debug.toString expr_

        Quote expr_ ->
            display expr_

        u ->
            "I don't know how to display that expression: " ++ Debug.toString expr
