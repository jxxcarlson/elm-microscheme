module MicroScheme.Error exposing (EvalError(..))

import MicroScheme.Frame as Frame


type EvalError
    = EvalError Int String
    | FR Frame.FrameError
