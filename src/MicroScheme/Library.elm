module MicroScheme.Library exposing (lookup)

import Dict


earningsTotals =
    [ "(define my-hours '((1 30) (1 30)))"
    , "(define (hours<hm h m) (roundTo 2 (+ h (/ m 60.0))))"
    , "(define (hours<hm' data) (hours<hm (car data) (car (cdr data))))"
    , "(define (hours<hm-data hm-data) (map hours<hm' hm-data))"
    , "(define (total-hours hours) (apply + (hours<hm-data hours)))"
    , "(define (earnings rate hours) (* rate (total-hours hours)))"
    , "(define (earnings+hours rate hours) (cons (total-hours hours) (roundTo 2 (earnings rate hours)) ))"
    , "(define (bar rate hours) (cons 1 (roundTo 2 (earnings rate hours)) ))"
    , "(define (foo rate hours) (cons 1 (total-hours hours)))"
    ]
        |> String.join ";; "


library : Dict.Dict String String
library =
    Dict.fromList [
    ( "earnings", earningsTotals )
    , ( "square", "(define (square x) (* x x))" )
    ]


lookup : String -> Maybe String
lookup programName =
    Dict.get programName library


