module MicroScheme.Eval exposing (display, eval)

import Maybe.Extra
import MicroScheme.Environment as Environment exposing (SymbolTable)
import MicroScheme.Expr exposing (Expr(..), SpecialForm(..))


{-|

    EXAMPLE

    > display <| eval (L [times, Z 2,  L [ times, L [ plus, Z 1, Z 2 ], L [ plus, Z 3, Z 4 ] ]])
    PLUS: Just (Z 7)
    PLUS: Just (Z 3)
    TIMES: Just (Z 21)
    TIMES: Just (Z 42)
    "42" : String

-}
eval : { symbolTable : SymbolTable, expr : Expr } -> { symbolTable : SymbolTable, maybeExpr : Maybe Expr }
eval { symbolTable, expr } =
    case expr of
        L [ SF Define, Str name, expr_ ] ->
            { symbolTable = Environment.addSymbol name expr_ symbolTable, maybeExpr = Just expr }

        _ ->
            { symbolTable = symbolTable, maybeExpr = evalMaybe (Just expr) }


evalMaybe : Maybe Expr -> Maybe Expr
evalMaybe maybeExpr =
    case maybeExpr of
        Nothing ->
            Nothing

        Just expr ->
            case expr of
                Z n ->
                    Just (Z n)

                F r ->
                    Just (F r)

                Sym s ->
                    Just (Sym s)

                L ((Sym "+") :: rest) ->
                    evalPlus (List.map (evalMaybe << Just) rest |> Maybe.Extra.values)

                L ((Sym "*") :: rest) ->
                    evalTimes (List.map (evalMaybe << Just) rest |> Maybe.Extra.values)

                _ ->
                    Nothing


evalPlus : List Expr -> Maybe Expr
evalPlus rest_ =
    case List.map unwrapInteger rest_ |> Maybe.Extra.combine of
        Nothing ->
            Nothing

        Just ints ->
            Just <| Z (List.sum ints)


evalTimes : List Expr -> Maybe Expr
evalTimes rest_ =
    case List.map unwrapInteger rest_ |> Maybe.Extra.combine of
        Nothing ->
            Nothing

        Just ints ->
            Just <| Z (List.product ints)


unwrapInteger : Expr -> Maybe Int
unwrapInteger expr =
    case expr of
        Z n ->
            Just n

        _ ->
            Nothing


display : Maybe Expr -> String
display maybeExpr =
    case maybeExpr of
        Nothing ->
            "error"

        Just expr ->
            case expr of
                Z n ->
                    String.fromInt n

                F x ->
                    String.fromFloat x

                Str s ->
                    s

                Sym s ->
                    s

                L [ SF Define, Str name, expr2 ] ->
                    "define " ++ name ++ " : " ++ display (Just expr2)

                u ->
                    "Unprocessable expression: " ++ Debug.toString u



-- Debug.toString u
