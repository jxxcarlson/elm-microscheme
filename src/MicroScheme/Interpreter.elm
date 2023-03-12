module MicroScheme.Interpreter exposing (State, init, input, step)

import Dict
import MicroScheme.Environment as Environment exposing (Environment)
import MicroScheme.Eval as Eval
import MicroScheme.Expr as Expr exposing (Expr(..), SpecialForm(..))
import MicroScheme.Frame as Frame exposing (Frame)
import MicroScheme.Init as Init
import MicroScheme.Parser as Parser


type alias State =
    { input : String
    , output : String
    , environment : Environment
    , rootFrame : Frame
    }


init : String -> State
init str =
    { input = str
    , output = ""
    , environment = Environment.initial
    , rootFrame = Init.symbolTable
    }


input : String -> State -> State
input str state =
    { state | input = str }


{-|

    > s1 = init "(define x 5)"
    { globalFrame = Dict.fromList [], input = "(define x 5)"
    , output = "", symbolTable = Dict.fromList [("*",Sym "*"),("+",Sym "+")] }

    > s2 = step s1
    { globalFrame = Dict.fromList [], input = "(define x 5)"
    , output = "define x : 5", symbolTable = Dict.fromList [("*",Sym "*"),("+",Sym "+"),("x",Z 5)] }

    > s3 = input "(+ x 1)" s2
    { globalFrame = Dict.fromList [], input = "(+ x 1)"
    , output = "define x : 5", symbolTable = Dict.fromList [("*",Sym "*"),("+",Sym "+"),("x",Z 5)] }

    > s4 = step s3
    { globalFrame = Dict.fromList [], input = "(+ x 1)"
    , output = "6", symbolTable = Dict.fromList [("*",Sym "*"),("+",Sym "+"),("x",Z 5)] }

-}
step : State -> State
step state =
    case Parser.parse state.rootFrame state.input of
        Err err ->
            { state
                | output = "Step error (1): " ++ Debug.toString err
            }

        Ok expr ->
            case expr of
                L [ SF Define, Str name, expr_ ] ->
                    { state | rootFrame = Frame.addSymbol name expr_ state.rootFrame, output = name }

                L [ SF Define, Str name, L args, L body ] ->
                    { state | rootFrame = Frame.addSymbol name (L [ SF Lambda, L args, L body ]) state.rootFrame, output = name }

                _ ->
                    case Eval.eval expr of
                        Err error ->
                            { state | output = Debug.toString error }

                        Ok value ->
                            { state | output = Eval.display value }
