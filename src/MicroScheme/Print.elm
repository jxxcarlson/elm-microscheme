module MicroScheme.Print exposing (print)

import MicroScheme.Expr exposing (Expr(..))


print : Expr -> String
print expr =
    -- expr |> print_ |> prefix "L " |> parens
    print_ expr


prefix : String -> String -> String
prefix p str =
    p ++ str


print_ : Expr -> String
print_ expr =
    case expr of
        Z n ->
            String.fromInt n

        F x ->
            String.fromFloat x

        B b ->
            if b then
                "True"

            else
                "False"

        Str str ->
            str

        Sym str ->
            "Sym " ++ quote str

        L exprs ->
            List.map print exprs |> String.join " " |> parens

        Pair a b ->
            [ print a, ".", print b ] |> String.join " " |> parens

        Lambda a b ->
            [ "lambda", print a, print b ] |> String.join " " |> parens

        Define a b ->
            [ "define", print a, print b ] |> String.join " " |> parens

        If a b c ->
            [ "if", print a, print b, print c ] |> String.join " " |> parens

        Display exprs ->
            List.map print exprs |> String.join " "

        Quote expr_ ->
            print expr_



-- HELPERS


parens : String -> String
parens str =
    "(" ++ str ++ ")"


bracket : String -> String
bracket str =
    "[" ++ str ++ "]"


quote : String -> String
quote str =
    "\"" ++ str ++ "\""
