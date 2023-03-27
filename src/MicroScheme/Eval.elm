module MicroScheme.Eval exposing (eval)

import MicroScheme.Environment as Environment exposing (Environment)
import MicroScheme.Error exposing (EvalError(..))
import MicroScheme.Expr exposing (Expr(..))
import MicroScheme.Frame as Frame
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
                L [ Sym "null?", L args ] ->
                    case eval env (L args) of
                        Ok (L []) ->
                            Ok (B True)

                        _ ->
                            Ok (B False)

                Z n ->
                    Ok (Z n)

                F r ->
                    Ok (F r)

                Str s ->
                    Ok (Frame.resolve [] (Environment.root env) expr)

                Sym s ->
                    Ok (Sym s)

                L [ Sym "atom?", L _ ] ->
                    Ok (B False)

                L [ Sym "atom?", _ ] ->
                    Ok (B True)

                L ((Sym "quote") :: arg :: []) ->
                    Ok (Quote arg) |> Debug.log "QUOTE (1)"

                L ((Sym "quote") :: args) ->
                    Ok (Quote (L args)) |> Debug.log "QUOTE (2)"

                L ((Sym "map") :: lambda :: args) ->
                    let
                        evaluatedArgs : Result EvalError (List Expr)
                        evaluatedArgs =
                            List.map (eval env) args |> Result.Extra.combine
                    in
                    case evaluatedArgs of
                        Ok [ L exprs ] ->
                            List.map (\item -> eval env (L (lambda :: item :: []))) exprs
                                |> Result.Extra.combine
                                |> Result.map L

                        _ ->
                            Err (EvalError 39 "can't evaluate map")

                L ((Sym "list") :: args) ->
                    Ok (L args)

                L [ Sym "cons", a, L b ] ->
                    case ( eval env a, eval env (L b) ) of
                        ( Ok aa, Ok bb ) ->
                            case bb of
                                L bb_ ->
                                    Ok (L (aa :: bb_)) |> Debug.log "CONs (1)"

                                Quote (L bbb_) ->
                                    Ok (L (aa :: bbb_))

                                Quote bbb_ ->
                                    Ok (Pair aa bbb_)

                                _ ->
                                    Ok (Pair aa bb) |> Debug.log "CONs (2)"

                        _ ->
                            Err (EvalError 23 "Could not evaluate components of cons")

                L [ Sym "cons", a, b ] ->
                    case ( eval env a, eval env b ) of
                        ( Ok aa, Ok bb ) ->
                            case bb of
                                Quote (L bbb) ->
                                    Ok (L (aa :: bbb)) |> Debug.log "CONs (3)"

                                Quote bbb ->
                                    Ok (Pair aa bbb) |> Debug.log "CONs (4)"

                                _ ->
                                    Ok (Pair aa bb) |> Debug.log "CONs (5)"

                        _ ->
                            Err (EvalError 24 "Could not evaluate components of pair")

                L ((Sym "car") :: arg :: []) ->
                    let
                        _ =
                            Debug.log "car (ARG)" arg
                    in
                    case eval env arg of
                        Ok (Quote arg2) ->
                            evalCar env arg2 |> Debug.log "CAR (2)"

                        _ ->
                            evalCar env arg |> Debug.log "CAR (3)"

                L ((Sym "cdr") :: args :: []) ->
                    case eval env args of
                        Ok (Quote args2) ->
                            evalCdr env args2

                        _ ->
                            evalCdr env args

                L [ Sym "apply", Sym functionName, L args ] ->
                    case eval env (L args) of
                        Ok (L realArgs) ->
                            dispatchFunction env functionName realArgs

                        Err error ->
                            Err error

                        _ ->
                            Err (EvalError 99 "invalid arguments to 'apply'")

                L ((Sym functionName) :: args) ->
                    case List.map (eval env) args |> Result.Extra.combine of
                        Ok evaluatedArgs ->
                            dispatchFunction env functionName evaluatedArgs

                        Err error ->
                            Err error

                L ((Lambda (L params) (L body)) :: args) ->
                    evalResult env (applyLambdaToExpressionList params body args)

                L ((Lambda (L params) body) :: args) ->
                    evalResult env (applyLambdaToExpression params body args)

                If (L boolExpr_) expr1 expr2 ->
                    evalBoolExpr env boolExpr_ expr1 expr2

                Quote expr_ ->
                    Ok (Quote expr_)

                L ((Str name) :: rest) ->
                    Err <| EvalError 0 ("Unknown symbol: " ++ name)

                L exprList_ ->
                    case List.map (eval env) exprList_ |> Result.Extra.combine of
                        Err _ ->
                            Err (EvalError 44 "weird!")

                        Ok result ->
                            Ok (L result)

                _ ->
                    Err <| EvalError 0 <| "Missing case (eval), expr = XXX"


dispatchFunction : Environment -> String -> List Expr -> Result EvalError Expr
dispatchFunction env functionName args =
    if functionName == "lookup" then
        Ok (Display args)

    else
        case Function.dispatch functionName of
            Err _ ->
                Err (EvalError 3 ("dispatch " ++ functionName ++ " did not return a value"))

            Ok f ->
                case evalArgs env args of
                    Err _ ->
                        Err (EvalError 5 functionName)

                    Ok actualArgs ->
                        f actualArgs


evalBoolExpr : Environment -> List Expr -> Expr -> Expr -> Result EvalError Expr
evalBoolExpr env boolExpr_ expr1 expr2 =
    let
        boolExpr : List Expr
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


evalCar : Environment -> Expr -> Result EvalError Expr
evalCar env args =
    case eval env args of
        Ok (Pair a _) ->
            Ok a

        Ok (L (a :: _)) ->
            Ok a

        _ ->
            Err (EvalError 33 "car: empty list")


evalCdr : Environment -> Expr -> Result EvalError Expr
evalCdr env args =
    case eval env args of
        Ok (Pair _ b) ->
            Ok b

        Ok (L (a :: rest)) ->
            Ok (L rest)

        _ ->
            Err (EvalError 33 "cdr: empty list")
