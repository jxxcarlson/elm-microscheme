module MicroScheme.Interpreter exposing (State, init, input, step)

import Dict
import MicroScheme.Environment as Environment exposing (Frame, SymbolTable)
import MicroScheme.Eval as Eval
import MicroScheme.Parser as Parser


type alias State =
    { input : String
    , output : String
    , symbolTable : SymbolTable
    , globalFrame : Frame
    }


init : String -> State
init str =
    { input = str
    , output = ""
    , symbolTable = Environment.symbolTable
    , globalFrame = Dict.empty
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
    case Parser.parse state.symbolTable state.input of
        Err err ->
            { state
                | output = "Error (1): " --  ++ Debug.toString err
            }

        Ok expr ->
            let
                data =
                    Eval.eval { symbolTable = state.symbolTable, expr = expr }
            in
            case data.maybeExpr of
                Nothing ->
                    { state | symbolTable = data.symbolTable, output = "Error (step)" }

                Just value ->
                    { state | symbolTable = data.symbolTable, output = Eval.display (Just value) }
