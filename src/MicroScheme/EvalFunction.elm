module MicroScheme.EvalFunction exposing (..)

evalCar
  case eval env args of
        Ok (Pair a _) ->
            Ok a


        Ok (L (a :: _)) ->
            Ok a

        _ ->
            Err (EvalError 33 "car: empty list")