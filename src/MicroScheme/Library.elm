module MicroScheme.Library exposing (lookup)

import Dict


earningsTotals =
    [ "(define my-hours (list (cons 1 20) (cons 2 40) (cons 1 14)))"
    , "(define (hours-from-hours-minutes h m) (roundTo 2 (+ h (/ m 60.0))))"
    , "(define (hours-from-hours-minutes-pair pair) (hours-from-hours-minutes (car pair) (cdr pair)))"
    , "(define (compute-hours hm-pairs) (map hours-from-hours-minutes-pair hm-pairs))"
    , "(define (total-hours hours) (apply + (compute-hours hours)))"
    , "(define (total-earnings rate hours) (* rate (total-hours hours)))"
    , "(define (earnings-totals rate hours) (cons (total-earnings rate hours) (total-hours hours)))"
    ]
        |> String.join ";; "


library : Dict.Dict String String
library =
    Dict.fromList [ ( "earnings-totals", earningsTotals ) ]


lookup : String -> Maybe String
lookup programName =
    Dict.get programName library
