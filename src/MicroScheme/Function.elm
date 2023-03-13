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
        , ( "roundTo", roundTo )
        ]


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
