module MicroScheme.Eval exposing (eval)

import MicroScheme.Environment as Environment exposing (Environment)
import MicroScheme.Error exposing (EvalError(..))
import MicroScheme.Expr exposing (Expr(..))
import MicroScheme.Frame as Frame exposing (Frame)
import MicroScheme.Function as Function
import Result.Extra


{-|

    EXAMPLE

    > display <| eval (L [times, Z 2,  L [ times, L [ plus, Z 1, Z 2 ], L [ plus, Z 3, Z 4 ] ]])
    PLUS: Just (Z 7)
    PLUS: Just (Z 3)
    TIMES: Just (Z 21)
    TIMES: Just (Z 42)
    "42" : String

-}
eval : Environment -> Expr -> Result EvalError Expr
eval env expr =
    evalResult env (Ok expr)


evalResult : Environment -> Result EvalError Expr -> Result EvalError Expr
evalResult env resultExpr =
    case resultExpr of
        Err error ->
            Err error

        Ok expr ->
            case expr of
                Z n ->
                    Ok (Z n)

                F r ->
                    Ok (F r)

                Str s ->
                    Ok (Frame.resolve [] (Environment.root env) expr)

                Sym s ->
                    Ok (Sym s)

                L ((Sym functionName) :: args) ->
                    dispatchFunction env functionName args

                L ((Lambda (L params) (L body)) :: args) ->
                    evalResult env (applyLambdaToExpressionList params body args)

                L ((Lambda (L params) body) :: args) ->
                    evalResult env (applyLambdaToExpression params body args)

                If (L boolExpr_) expr1 expr2 ->
                    evalBoolExpr env boolExpr_ expr1 expr2

                L ((Str name) :: rest) ->
                    Err <| EvalError 0 ("Unknown symbol: " ++ name)

                L exprList_ ->
                    Err <| EvalError -1 <| "!!! "

                _ ->
                    Err <| EvalError 0 <| "Missing case (eval), expr = XXX"


dispatchFunction env functionName args =
    case Function.dispatch functionName of
        Err _ ->
            Err (EvalError 3 ("dispatch " ++ functionName ++ " did not return a value"))

        Ok f ->
            case evalArgs env args of
                Err _ ->
                    Err (EvalError 5 functionName)

                Ok actualArgs ->
                    f actualArgs


evalBoolExpr env boolExpr_ expr1 expr2 =
    let
        boolExpr =
            List.map (Environment.resolve [] env) boolExpr_
    in
    case eval env (L boolExpr) of
        Err _ ->
            Err (EvalError 4 "Error evaluating predicate:")

        Ok truthValue ->
            case truthValue of
                B True ->
                    case eval env expr1 of
                        Err _ ->
                            Err (EvalError 4 "True, error evaluating: XXX")

                        Ok value ->
                            Ok value

                B False ->
                    case eval env expr2 of
                        Err _ ->
                            Err (EvalError 4 "False, error evaluating: XXX")

                        Ok value ->
                            Ok value

                _ ->
                    Err (EvalError 4 "False, error evaluating predicate")


evalArgs : Environment -> List Expr -> Result EvalError (List Expr)
evalArgs env args =
    List.map (\arg -> evalResult env (Ok arg)) args |> Result.Extra.combine


applyLambdaToExpression : List Expr -> Expr -> List Expr -> Result EvalError Expr
applyLambdaToExpression params body args =
    let
        -- `A throw-away frame. It will never be used
        -- outside of this function.
        frameResult : Result Frame.FrameError Frame.Frame
        frameResult =
            Frame.addBindings (Frame.varNames params) args Frame.empty
    in
    case frameResult of
        Err frameError ->
            Err frameError |> Result.mapError (\err -> FR err)

        Ok frame ->
            Ok (Frame.resolve [] frame body)


applyLambdaToExpressionList : List Expr -> List Expr -> List Expr -> Result EvalError Expr
applyLambdaToExpressionList params body args =
    let
        -- `A throw-away frame. It will never be used
        -- outside of this function.
        frameResult : Result Frame.FrameError Frame.Frame
        frameResult =
            Frame.addBindings (Frame.varNames params) args Frame.empty
    in
    case frameResult of
        Err frameError ->
            Err frameError |> Result.mapError (\err -> FR err)

        Ok frame ->
            Ok (List.map (Frame.resolve [] frame) body |> L)
