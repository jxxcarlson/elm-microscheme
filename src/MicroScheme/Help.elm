module MicroScheme.Help exposing (lookup, text)



import Dict exposing (Dict)


helpDict : Dict String String
helpDict = Dict.fromList
  [("cons", "(cons 1 2) => (1 . 2); (cons 1 '(2 3)' => (1 2 3)")
  ,("car", "(car (cons 1 2)) => 1; (car '(1 2 3) => 1")
  ]


lookup : String -> String
lookup symbol =
    case Dict.get symbol helpDict of
        Just info -> info
        Nothing -> "No info for " ++ symbol

text : String
text =
    """
    Examples:
    ===========================

    > (+ 2 3)
    5

    > (define (square x) (* x x))
    square

    > (square 3)
    9

    > env ; print the environment
    > env square ; lookup square in the environment
    (lambda (x) (Sym "*" x x)

    > info cons
    (cons 1 2) => (1 . 2); (cons 1 '(2 3)' => (1 2 3)

"""
