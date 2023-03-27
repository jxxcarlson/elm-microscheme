module MicroScheme.Help exposing (lookup)



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

    ===========================
    
    Environment
    -----------
    
    > (lookup square) -- lookup 'square' in the environment
    [Lambda (L [Str "x"]) (L [Sym "*",Str "x",Str "x"])]

    > lookup
    -- display the environment
    ===========================
    
    Debug
    -----
    
    > (+ 1 2)
    3
    > debug
      true
    > (+ 1 2)
    PARSE: Ok (L [Sym "+",Z 1,Z 2])
    3
    > debug
    PARSE: Ok (Sym "debug")
    false
    > (+ 1 2)
    3
    
    > 
    
    
"""
