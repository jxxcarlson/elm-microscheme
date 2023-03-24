module MicroScheme.Help exposing (text)

text : String
text = """
    Examples:
    ==================

    > (+ 2 3)
    5

    > (define (square x) (* x x))
    square

    > (square 3)
    9

    > (lookup square) -- lookup 'square' in the environment
    [Lambda (L [Str "x"]) (L [Sym "*",Str "x",Str "x"])]

    > lookup
    -- display the environment
    ===========================
"""