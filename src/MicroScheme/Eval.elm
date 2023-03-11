module MicroScheme.Eval exposing (display, eval)

import Maybe.Extra
import MicroScheme.Expr exposing (Expr(..))


{-|

    EXAMPLE

    > display <| eval (L [times, Z 2,  L [ times, L [ plus, Z 1, Z 2 ], L [ plus, Z 3, Z 4 ] ]])
    PLUS: Just (Z 7)
    PLUS: Just (Z 3)
    TIMES: Just (Z 21)
    TIMES: Just (Z 42)
    "42" : String

-}
eval : Expr -> Maybe Expr
eval expr =
    evalMaybe (Just expr)


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
                    evalPlus (List.map (evalMaybe << Just) rest |> Maybe.Extra.values) |> Debug.log "PLUS"

                L ((Sym "*") :: rest) ->
                    evalTimes (List.map (evalMaybe << Just) rest |> Maybe.Extra.values) |> Debug.log "TIMES"

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

                u ->
                    Debug.toString u
