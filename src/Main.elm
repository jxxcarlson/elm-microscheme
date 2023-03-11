port module Main exposing (main)

import BlackBox
import Cmd.Extra exposing (withCmd, withCmds, withNoCmd)
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
    {}


type Msg
    = Input String


type alias Flags =
    ()


init : () -> ( Model, Cmd Msg )
init _ =
    {} |> withNoCmd


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ get Input ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input input ->
            -- model |> withCmd (put <| BlackBox.transform input)
            model |> withCmd (put (BlackBox.transform input))
