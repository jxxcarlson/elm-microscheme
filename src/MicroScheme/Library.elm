module MicroScheme.Library exposing (lookup)

import Dict


earningsTotals =
    [ "(define my-hours '((1 30) (1 30)))"
    , "(define (hours-from-hours-minutes h m) (roundTo 2 (+ h (/ m 60.0))))"
    , "(define (hours-from-hours-minutes' data) (hours-from-hours-minutes (car data) (car (cdr data))))"
    , "(define (compute-hours hm-data) (map hours-from-hours-minutes-pair' hm-data))"
    , "(define (total-hours hours) (apply + (compute-hours hours)))"
    , "(define (total-earnings rate hours) (* rate (total-hours hours)))"
    , "(define (earnings-totals rate hours) (cons (total-hours hours) (roundTo 2 (total-earnings rate hours)) ))"
    ]
        |> String.join ";; "


library : Dict.Dict String String
library =
    Dict.fromList [ ( "earnings-totals", earningsTotals ) ]


lookup : String -> Maybe String
lookup programName =
    Dict.get programName library


