module MicroScheme.Interpreter exposing (..)

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
init input =
    { input = input
    , output = ""
    , symbolTable = Environment.symbolTable
    , globalFrame = Dict.empty
    }


step : State -> State
step state =
    case Parser.parse state.symbolTable state.input of
        Err err ->
            { state | output = "Error (1): " ++ Debug.toString err }

        Ok expr ->
            case Eval.eval expr of
                Nothing ->
                    { state | output = "Error (2): " ++ Debug.toString expr }

                Just value ->
                    { state | output = Eval.display (Just value) }



-- HELPERS


type Step state a
    = Loop state
    | Done a


loop : state -> (state -> Step state a) -> a
loop s f =
    case f s of
        Loop s_ ->
            loop s_ f

        Done b ->
            b
