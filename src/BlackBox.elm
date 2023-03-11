module BlackBox exposing (transform)

import MicroScheme.Interpreter


transform : String -> String
transform input_ =
    let
        input =
            String.trim input_

        state =
            MicroScheme.Interpreter.init input
    in
    (MicroScheme.Interpreter.step state).output
