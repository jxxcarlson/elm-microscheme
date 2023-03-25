module MicroScheme.Function exposing (dispatch)

import Dict exposing (Dict)
import Either exposing (Either(..))
import MicroScheme.Error exposing (EvalError(..))
import MicroScheme.Expr exposing (Expr(..))
import MicroScheme.Numbers as Numbers


dispatch : String -> Result EvalError (List Expr -> Result EvalError Expr)
dispatch functionName =
    case Dict.get functionName functionDict of
        Nothing ->
            Err (EvalError 2 ("eval dispatch, no such function: " ++ functionName))

        Just f ->
            Ok f


functionDict : Dict String (List Expr -> Result EvalError Expr)
functionDict =
    Dict.fromList
        [ ( "+", evalPlus )
        , ( "*", evalTimes )
        , ( "-", evalMinus )
        , ( "/", evalDivide )
        , ( "roundTo", roundTo )
        , ( "=", equalNumbers )
        , ( "<", ltPredicate )
        , ( ">", gtPredicate )
        , ( "<=", ltePredicate )
        , ( ">=", gtePredicate )
        , ( "remainder", remainder )
        , ( "lookup", displayEnvironment )
        , ( "null?", null )
        ]


displayEnvironment : List Expr -> Result EvalError Expr
displayEnvironment exprs =
    Ok (L (Str "env" :: exprs))


remainder : List Expr -> Result EvalError Expr
remainder exprs =
    case exprs of
        (Z a) :: (Z b) :: [] ->
            Ok (Z (modBy b a))

        _ ->
            Err (EvalError 1 "bad arguments to: remainder")


evalMinus : List Expr -> Result EvalError Expr
evalMinus exprs =
    case exprs of
        (Z a) :: (Z b) :: [] ->
            Ok (Z (a - b))

        (F a) :: (F b) :: [] ->
            Ok (F (a - b))

        (F a) :: (Z b) :: [] ->
            Ok (F (a - toFloat b))

        (Z a) :: (F b) :: [] ->
            Ok (F (toFloat a - b))

        _ ->
            Err (EvalError 81 "bad arguments to -")


evalDivide : List Expr -> Result EvalError Expr
evalDivide exprs =
    case exprs of
        (Z a) :: (Z b) :: [] ->
            Ok (Z (a // b))

        (F a) :: (F b) :: [] ->
            Ok (F (a / b))

        (F a) :: (Z b) :: [] ->
            Ok (F (a / toFloat b))

        (Z a) :: (F b) :: [] ->
            Ok (F (toFloat a / b))

        _ ->
            Err (EvalError 81 "bad arguments to -")


ltPredicate : List Expr -> Result EvalError Expr
ltPredicate exprs =
    case exprs of
        (Z a) :: (Z b) :: [] ->
            Ok (B (a < b))

        (F a) :: (F b) :: [] ->
            Ok (B (a < b))

        _ ->
            Ok (B False)


gtPredicate : List Expr -> Result EvalError Expr
gtPredicate exprs =
    case exprs of
        (Z a) :: (Z b) :: [] ->
            Ok (B (a > b))

        (F a) :: (F b) :: [] ->
            Ok (B (a > b))

        _ ->
            Ok (B False)


ltePredicate : List Expr -> Result EvalError Expr
ltePredicate exprs =
    case exprs of
        (Z a) :: (Z b) :: [] ->
            Ok (B (a <= b))

        (F a) :: (F b) :: [] ->
            Ok (B (a <= b))

        _ ->
            Ok (B False)


gtePredicate : List Expr -> Result EvalError Expr
gtePredicate exprs =
    case exprs of
        (Z a) :: (Z b) :: [] ->
            Ok (B (a >= b))

        (F a) :: (F b) :: [] ->
            Ok (B (a >= b))

        _ ->
            Ok (B False)


null : List Expr -> Result EvalError Expr
null exprs =
    if exprs == [] then
        Ok (B True)

    else
        Ok (B False)


equalNumbers : List Expr -> Result EvalError Expr
equalNumbers exprs =
    case exprs of
        (Z a) :: (Z b) :: [] ->
            Ok (B (a == b))

        (F a) :: (F b) :: [] ->
            Ok (B (a == b))

        _ ->
            Ok (B False)


roundTo : List Expr -> Result EvalError Expr
roundTo exprs =
    case exprs of
        (Z n) :: (F x) :: [] ->
            Ok (F (Numbers.roundTo n x))

        _ ->
            Err (EvalError 1 "bad arguments to function roundTo")


evalPlus : List Expr -> Result EvalError Expr
evalPlus rest_ =
    case Numbers.coerce rest_ of
        Err _ ->
            Err (EvalError 1 "Could not unwrap argument to evalPlus")

        Ok (Left ints) ->
            Ok <| Z (List.sum ints)

        Ok (Right floats) ->
            Ok <| F (List.sum floats)


evalTimes : List Expr -> Result EvalError Expr
evalTimes rest_ =
    case Numbers.coerce rest_ of
        Err _ ->
            Err (EvalError 1 "Could not unwrap argument to evalPlus")

        Ok (Left ints) ->
            Ok <| Z (List.product ints)

        Ok (Right floats) ->
            Ok <| F (List.product floats)
