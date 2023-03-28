module MicroScheme.Help exposing (lookup, text, topics)



import Dict exposing (Dict)


helpDict : Dict String String
helpDict = Dict.fromList
  [("cons", "(cons 1 2) => (1 . 2); (cons 1 '(2 3)' => (1 2 3)")
  ,("car", "(car (cons 1 2)) => 1; (car '(1 2 3) => 1")
  ,("cdr", "(cdr (cons 1 2)) => d; (cdr '(1 2 3) => (2 3)")
  ,("if", "(if (< -2 0) -1 1) => -1")
  ,("define", "(define (double x) (* 2 x)); (double 3) => 6")
  ,("load", "  -- 'load square' loads 'square' into the environment if 'square' is in the library")
  ,("env",  "  -- prints the root environment;\n  'env square' prints the value of 'square' in the environment")
  ,("info", "  -- 'info foo' displays information about 'foo'; try 'info cons'")
  ]

topics : String
topics = Dict.keys helpDict |> List.sort |> List.map (\x -> "  " ++ x) |> String.join "\n"

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

    > info topics ... prints a list of topics, e.g., cons

"""
