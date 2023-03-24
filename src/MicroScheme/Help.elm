module MicroScheme.Help exposing (text)


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
