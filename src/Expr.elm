module Expr exposing (..)

import Maybe.Extra


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


eval : Expr -> Maybe Expr
eval expr =
    evalMaybe2 (Just expr)


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
                    evalPlus rest |> Debug.log "PLUS"

                L ((Sym "*") :: rest) ->
                    evalTimes rest |> Debug.log "Times"

                _ ->
                    Nothing


evalMaybe2 : Maybe Expr -> Maybe Expr
evalMaybe2 maybeExpr =
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
                    evalPlus (List.map (evalMaybe2 << Just) rest |> Maybe.Extra.values) |> Debug.log "PLUS"

                L ((Sym "*") :: rest) ->
                    evalTimes (List.map (evalMaybe2 << Just) rest |> Maybe.Extra.values) |> Debug.log "TIMES"

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
