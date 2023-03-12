module MicroScheme.Eval exposing (display, eval)

import Maybe.Extra
import MicroScheme.Environment as Environment exposing (SymbolTable)
import MicroScheme.Expr exposing (Expr(..), SpecialForm(..))
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
eval : { symbolTable : SymbolTable, expr : Expr } -> { symbolTable : SymbolTable, resultExpr : Result EvalError Expr }
eval { symbolTable, expr } =
    case expr of
        L [ SF Define, Str name, expr_ ] ->
            { symbolTable = Environment.addSymbol name expr_ symbolTable, resultExpr = Ok expr }

        L [ SF Define, Str name, L args, L body ] ->
            { symbolTable = Environment.addSymbol name (L [ SF Lambda, L args, L body ]) symbolTable |> Debug.log "SYMTABLE"
            , resultExpr = Ok expr
            }

        _ ->
            { symbolTable = symbolTable, resultExpr = evalResult (Ok expr) }


type EvalError
    = EvalError Int String
    | FR Environment.FrameError


evalResult : Result EvalError Expr -> Result EvalError Expr
evalResult resultExpr =
    case resultExpr of
        Err error ->
            Err error

        Ok expr ->
            let
                _ =
                    Debug.log "EXPR (in evalResult)" expr
            in
            case expr of
                Z n ->
                    Ok (Z n)

                F r ->
                    Ok (F r)

                Sym s ->
                    Ok (Sym s)

                L ((Sym "+") :: rest) ->
                    let
                        args : Result EvalError (List Expr)
                        args =
                            List.map (evalResult << Ok) rest |> Result.Extra.combine
                    in
                    Result.map evalPlus args |> Result.Extra.join

                L ((Sym "*") :: rest) ->
                    let
                        args : Result EvalError (List Expr)
                        args =
                            List.map (evalResult << Ok) rest |> Result.Extra.combine
                    in
                    Result.map evalTimes args |> Result.Extra.join

                L ((L ((SF Lambda) :: (L params) :: (L body) :: [])) :: args) ->
                    applyLambda params body args |> evalResult

                _ ->
                    Err <| EvalError 0 "Missing case"



-- L [ L [ SF Lambda, L params, L body ], arg ] ->


bozo =
    L [ SF Lambda, L [ Str "x", Str "y" ], L [ Sym "+", Str "x", Str "y" ] ]


bobo =
    L [ L [ SF Lambda, L [ Str "x", Str "y" ], L [ Sym "+", Str "x", Str "y" ] ], Z 5, Z 7 ]


yolo =
    L [ L [ SF Lambda, L [ Str "x" ], L [ Sym "*", Str "x", Str "x" ] ], Z 2 ]


applyLambda : List Expr -> List Expr -> List Expr -> Result EvalError Expr
applyLambda params body args =
    let
        frameResult : Result Environment.FrameError Environment.Frame
        frameResult =
            Environment.addBindings (Environment.varNames params) args Environment.emptyFrame
    in
    case frameResult of
        Err frameError ->
            Err frameError |> Result.mapError (\err -> FR err)

        Ok frame ->
            Ok (List.map (Environment.applyFrame frame) body |> L)



-- |> Result.mapError (\err -> F err)


evalPlus : List Expr -> Result EvalError Expr
evalPlus rest_ =
    case List.map unwrapInteger rest_ |> Maybe.Extra.combine of
        Nothing ->
            Err <| EvalError 1 "Could not unwrap argument to evalPlus"

        Just ints ->
            Ok <| Z (List.sum ints)


evalTimes : List Expr -> Result EvalError Expr
evalTimes rest_ =
    case List.map unwrapInteger rest_ |> Maybe.Extra.combine of
        Nothing ->
            Err <| EvalError 1 "Could not unwrap argument to evalTimes"

        Just ints ->
            Ok <| Z (List.product ints)


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

        L [ SF Define, Str name, expr2 ] ->
            "define " ++ name ++ " : " ++ display expr2

        u ->
            "Unprocessable expression: " ++ Debug.toString u
