module MicroScheme.Interpreter exposing (State, init, input, runProgram, step)

import Dict
import Maybe.Extra
import MicroScheme.Environment as Environment exposing (Environment)
import MicroScheme.Eval as Eval
import MicroScheme.Expr as Expr exposing (Expr(..))
import MicroScheme.Frame as Frame exposing (Frame)
import MicroScheme.Help as Help
import MicroScheme.Library as Library
import MicroScheme.Parser as Parser
import Parser exposing (DeadEnd)


type alias State =
    { input : String
    , output : String
    , environment : Environment
    , debug : Bool
    }


init : String -> State
init str =
    { input = str
    , output = ""
    , environment = Environment.initial
    , debug = False
    }


input : String -> State -> State
input str state =
    { state | input = String.trim str }



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
    case isCommand state of
        (True, commandLength) -> handleCommand state commandLength
        (False, _) -> doStep state

doStep state =
        let
            parsed : Result (List DeadEnd) Expr
            parsed =
                Parser.parse state.input
                    |> Result.map (Frame.resolve [] (Environment.root state.environment))
                    |> (if state.debug then
                            identity --Debug.log "  PARSE:: "

                        else
                            identity
                       )
        in
        case parsed of
            Err err ->
                { state
                    | output = "Parse error"
                }

            Ok expr ->
                case expr of
                    Sym "env" ->
                        { state | output = Frame.print (Environment.root state.environment) }

                    Sym "debug" ->
                        handleDebug state

                    Define (Str name) value ->
                        handleDefine1 state name value

                    Define (L ((Str name) :: args)) (L body) ->
                        handleDefine2 state name args body

                    Define (L ((Str name) :: args)) body ->
                        handleDefine3 state name args body

                    _ ->
                        handleMissingCase state expr


handleDebug state =
    let
        newDebug =
            not state.debug
    in
    { state
        | debug = newDebug
        , output =
            if newDebug then
                "  true"

            else
                "  false"
    }


isCommand : State -> (Bool, Int)
isCommand state =
    let
        maybeCommand = state.input |> String.words |> List.head
    in
    (case maybeCommand of
        Nothing -> (False, 0)
        Just command ->
            (List.member command commandNames, String.length command))

commandNames = ["help", "info", "env", "run", "lookup", "lookup-program"]


handleCommand state commandSize =
  let
      cmdSize = commandSize + 1
  in
     if String.left cmdSize state.input == "Ok" then
         let
             exprString =
                 String.dropLeft cmdSize state.input
         in
         { state | output = exprString }


     else if String.left cmdSize state.input == "env " then
        let
          symbol = String.dropLeft cmdSize state.input
          value = case Dict.get symbol (Environment.root state.environment |> .bindings) of
                Nothing -> "Unknown symbol"
                Just expr -> Expr.print expr
        in
              { state | output = value }

     else if String.left commandSize state.input == "env" then
         { state | output = Frame.print (Environment.root state.environment) }

     else if  String.left commandSize state.input == "help" then
                     { state | output = Help.text}

     else if String.left cmdSize state.input == "info " then
        { state | output = Help.lookup (String.dropLeft cmdSize state.input)}

     else if String.left cmdSize state.input == "run " then
         let
             inputList =
                 String.split ";;" (String.dropLeft cmdSize state.input)
         in
         runProgram_ inputList state

     else if String.left cmdSize state.input == "lookup-program " then
         case Library.lookup (String.dropLeft cmdSize state.input) of
             Nothing ->
                 { state | output = "Sorry, no such program" }

             Just program ->
                 runProgram_ (String.split ";;" program) state
     else state

handleDefine1 state name value =
    { state | environment = Environment.addSymbolToRoot name value state.environment, output = name }


handleDefine2 state name args body =
    let
        argStrings : List String
        argStrings =
            let
                mapper : Expr -> Maybe String
                mapper expr_ =
                    case expr_ of
                        Str s ->
                            Just s

                        _ ->
                            Nothing
            in
            List.map mapper args |> Maybe.Extra.values

        newBody : List Expr
        newBody =
            List.map (Frame.resolve argStrings (Environment.root state.environment)) body

        value : Expr
        value =
            Lambda (L args) (L newBody)
    in
    { state | environment = Environment.addSymbolToRoot name value state.environment, output = name }


handleDefine3 state name args body =
    let
        value : Expr
        value =
            Lambda (L args) body
    in
    { state | environment = Environment.addSymbolToRoot name value state.environment, output = name }


handleMissingCase state expr =
    case Eval.eval state.environment expr of
        Err error ->
            { state | output = "error (17, missing pattern?): could not evaluate expr:: " ++ Expr.print expr }

        Ok value ->
            { state | output = Expr.print value }


{-|

    TODO: BUG
    > (define (isEven x ) ((remainder x 2 ) = 0 ) )
    ENV: Zipper { after = [], before = [], crumbs = [], focus = Tree { bindings = Dict.fromList [("*",Sym "*"),("+",Sym "+"),("<",Sym "<"),("<=",Sym "<="),("=",Sym "="),(">",Sym ">"),(">=",Sym ">="),("isEven",L [SF Lambda,L [Str "x"],L [L [Sym "remainder",Str "x",Z 2],Sym "=",Z 0]]),("remainder",Sym "remainder"),("roundTo",Sym "roundTo"),("square",L [SF Lambda,L [Str "x"],L [Sym "*",Str "x",Str "x"]])], id = 0 } [] }
    isEven
    > (isEven 2)
    EvalError 0 "Missing case (eval)"

    > runProgram ";" "(define x 5); (* 5 5)"
    "25"

    > runProgram "\n" "(define x 5)\n (* 5 5)"
    "25"

-}
runProgram : String -> String -> String
runProgram separator inputString =
    let
        inputList : List String
        inputList =
            inputString |> String.split separator |> List.map String.trim

        initialState : State
        initialState =
            init ""

        finalState : State
        finalState =
            List.foldl (\str state_ -> state_ |> input str |> step) initialState inputList
    in
    finalState.output


runProgram_ : List String -> State -> State
runProgram_ inputList state =
    List.foldl (\str state_ -> state_ |> input str |> step) state inputList
