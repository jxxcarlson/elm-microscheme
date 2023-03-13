module MicroScheme.Eval exposing (eval)

import MicroScheme.Error exposing (EvalError(..))
import MicroScheme.Expr exposing (Expr(..), SpecialForm(..))
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
eval : Expr -> Result EvalError Expr
eval expr =
    evalResult (Ok expr)


evalResult : Result EvalError Expr -> Result EvalError Expr
evalResult resultExpr =
    case resultExpr of
        Err error ->
            Err error

        Ok expr ->
            case expr of
                Z n ->
                    Ok (Z n)

                F r ->
                    Ok (F r)

                Sym s ->
                    Ok (Sym s)

                L ((Sym "+") :: rest) ->
                    Result.map Function.evalPlus (evalArgs rest) |> Result.Extra.join

                L ((Sym "*") :: rest) ->
                    Result.map Function.evalTimes (evalArgs rest) |> Result.Extra.join

                L ((Sym "roundTo") :: rest) ->
                    Result.map Function.roundTo (evalArgs rest) |> Result.Extra.join

                L ((L ((SF Lambda) :: (L params) :: (L body) :: [])) :: args) ->
                    applyLambda params body args |> evalResult

                _ ->
                    Err <| EvalError 0 "Missing case (eval)"


evalArgs : List Expr -> Result EvalError (List Expr)
evalArgs args =
    List.map (evalResult << Ok) args |> Result.Extra.combine


applyLambda : List Expr -> List Expr -> List Expr -> Result EvalError Expr
applyLambda params body args =
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
            Ok (List.map (Frame.resolve frame) body |> L)
