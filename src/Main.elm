port module Main exposing (main)

import BlackBox
import Cmd.Extra exposing (withCmd, withCmds, withNoCmd)
import MicroScheme.Interpreter as Interpreter
import Platform exposing (Program)


port get : (String -> msg) -> Sub msg


port put : String -> Cmd msg


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { state : Interpreter.State }


type Msg
    = Input String


type alias Flags =
    ()


init : () -> ( Model, Cmd Msg )
init _ =
    { state = Interpreter.init "" } |> withNoCmd


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ get Input ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input input ->
            let
                state1 =
                    Interpreter.input input model.state

                state2 =
                    Interpreter.step state1

                output =
                    state2.output

                -- model |> withCmd (put <| BlackBox.transform input)
            in
            { model | state = state2 } |> withCmd (put output)
