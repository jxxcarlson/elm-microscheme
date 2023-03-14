module MicroScheme.Eval exposing (eval)

import MicroScheme.Environment exposing (Environment)
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
eval : Environment -> Expr -> ( Environment, Result EvalError Expr )
eval env expr =
    evalResult ( env, Ok expr )


evalResult : ( Environment, Result EvalError Expr ) -> ( Environment, Result EvalError Expr )
evalResult ( env, resultExpr ) =
    case resultExpr of
        Err error ->
            ( env, Err error )

        Ok expr ->
            case expr of
                Z n ->
                    ( env, Ok (Z n) )

                F r ->
                    ( env, Ok (F r) )

                Sym s ->
                    ( env, Ok (Sym s) )

                L ((Sym name) :: rest) ->
                    case Function.dispatch name of
                        Err _ ->
                            ( env, Err (EvalError 3 ("dispatch " ++ name ++ " did not return a value")) )

                        Ok f ->
                            let
                                g : List Expr -> Result EvalError Expr
                                g =
                                    f

                                result : ( Environment, Result EvalError (List Expr) )
                                result =
                                    evalArgs env rest
                            in
                            case evalArgs env rest of
                                ( env_, Err _ ) ->
                                    ( env_, Err (EvalError 5 name) )

                                ( env_, Ok actualArgs ) ->
                                    ( env_, f actualArgs )

                L ((Lambda (L params) (L body)) :: args) ->
                    evalResult ( env, applyLambda params body args )

                --(Lambda (L params) (L body)) (L args) ->
                --    applyLambda params body args |> evalResult
                --L ((L ((SF Lambda) :: (L params) :: (L body) :: [])) :: args) ->
                --    applyLambda params body args |> evalResult
                -- (L [SF If,L [L [SF Lambda,L [Str "n"],L [Sym "=",L [Sym "remainder",Str "n",Z 2],Z 0]],Z 4],Z 0,Z 1])
                --L ((L ((SF Lambda) :: (L params) :: (L body) :: [])) :: args) ->
                --    Debug.todo "IF-LAMBDA"
                --L ((SF If) :: (L ((Sym name) :: args)) :: expr1 :: expr2 :: []) ->
                --    case eval (L (Sym name :: args)) of
                --        Err _ ->
                --            Err (EvalError 4 ("Error evaluating predicate: " ++ name))
                --
                --        Ok truthValue ->
                --            case truthValue of
                --                B True ->
                --                    case eval expr1 of
                --                        Err _ ->
                --                            Err (EvalError 4 "True, error evaluating predicate")
                --
                --                        Ok value ->
                --                            Ok value
                --
                --                B False ->
                --                    case eval expr2 of
                --                        Err _ ->
                --                            Err (EvalError 4 "False, error evaluating predicate")
                --
                --                        Ok value ->
                --                            Ok value
                --
                --                _ ->
                --                    Err (EvalError 4 "False, error evaluating predicate")
                L ((Str name) :: rest) ->
                    ( env, Err <| EvalError 0 ("Unknown symbol: " ++ name) )

                _ ->
                    ( env, Err <| EvalError 0 <| "Missing case (eval): " ++ Debug.toString expr )


evalArgs : Environment -> List Expr -> ( Environment, Result EvalError (List Expr) )
evalArgs env args =
    let
        result : Result EvalError (List Expr)
        result =
            List.map (\arg -> evalResult ( env, Ok arg )) args |> List.map Tuple.second |> Result.Extra.combine
    in
    ( env, result )


applyLambda : List Expr -> List Expr -> List Expr -> Result EvalError Expr
applyLambda params body args =
    let
        -- `A throw-away frame. It will never be used
        -- outside of this function.
        frameResult : Result Frame.FrameError Frame.Frame
        frameResult =
            Frame.addBindings (Frame.varNames params) args Frame.empty |> Debug.log "BINDINGS"
    in
    case frameResult of
        Err frameError ->
            Err frameError |> Result.mapError (\err -> FR err) |> Debug.log "applyLambda (1)"

        Ok frame ->
            Ok (List.map (Frame.resolve frame) body |> L) |> Debug.log "applyLambda (2)"
