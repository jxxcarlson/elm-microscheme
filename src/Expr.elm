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
    case expr of
        Z n ->
            Just (Z n)

        F r ->
            Just (F r)

        Sym s ->
            Just (Sym s)

        L ((Sym "+") :: rest) ->
            evalPlus rest

        L ((Sym "*") :: rest) ->
            evalTimes rest

        _ ->
            Nothing


evalPlus rest =
    case List.map eval rest |> Maybe.Extra.combine of
        Nothing ->
            Nothing

        Just values ->
            case List.map unwrapInteger values |> Maybe.Extra.combine of
                Nothing ->
                    Nothing

                Just ints ->
                    Just <| Z (List.sum ints)


evalTimes rest =
    case List.map eval rest |> Maybe.Extra.combine of
        Nothing ->
            Nothing

        Just values ->
            case List.map unwrapInteger values |> Maybe.Extra.combine of
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


display : Expr -> String
display expr =
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
    [ times, L [ plus, Z 1, Z 2 ], L [ plus, Z 3, Z 4 ] ]
