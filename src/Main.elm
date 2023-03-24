port module Main exposing (Flags, Model, Msg(..), main)

import Cmd.Extra exposing (withCmd, withNoCmd)
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
            if input == "\n" then
                model |> withCmd (put "")

            else
                let
                    state1 : Interpreter.State
                    state1 =
                        Interpreter.input input model.state

                    state2 : Interpreter.State
                    state2 =
                        Interpreter.step state1

                    output : String
                    output =
                        state2.output
                in
                { model | state = state2 } |> withCmd (put output)
