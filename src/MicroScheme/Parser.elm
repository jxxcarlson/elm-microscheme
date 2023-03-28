module MicroScheme.Parser exposing (parse)

import MicroScheme.Expr exposing (Expr(..))
import MicroScheme.Frame exposing (Frame)
import Parser as P exposing ((|.), (|=))


{-|

    TODO: BUG!
    > (define (isEven n) (= (remainder n 2) 0))
    Parse error: [{ col = 1, problem = ExpectingSymbol ")", row = 2 }]

    > parse symbolTable "(plus 33 44)"
    Ok (L [Sym "plus",Z 33,Z 44])

    > newSymbolTable = addSymbol "x" (Sym "x") symbolTable
    Dict.fromList [("plus",Sym "plus"),("times",Sym "times"),("x",Sym "x")]

    > parse newSymbolTable "(plus x 2)"
    Ok (L [Sym "plus",Sym "x",Z 2])

-}
parse : String -> Result (List P.DeadEnd) Expr
parse str =
    P.run exprParser str



--


exprParser : P.Parser Expr
exprParser =
    P.oneOf
        [ quotedExpression
        , P.backtrackable pairParser
        , lambdaParser
        , defineParser
        , ifParser
        , P.backtrackable negativeFloatParser
        , P.lazy (\_ -> listParser)
        , P.backtrackable intParser
        , P.backtrackable negativeIntParser
        , stringParser
        , P.lazy (\_ -> defineParser)

        , floatParser
        ]


quotedExpression : P.Parser Expr
quotedExpression =
    P.succeed Quote
        |. P.symbol "'"
        |= P.lazy (\_ -> exprParser)


pairParser : P.Parser Expr
pairParser =
    P.succeed Pair
        |. P.symbol "("
        |. P.spaces
        |= P.lazy (\_ -> exprParser)
        |. P.spaces
        |. P.symbol ","
        |. P.spaces
        |= P.lazy (\_ -> exprParser)
        |. P.spaces
        |. P.symbol ")"


ifParser : P.Parser Expr
ifParser =
    P.succeed If
        |. P.symbol "(if "
        |. P.spaces
        |= P.lazy (\_ -> exprParser)
        |. P.spaces
        |= P.lazy (\_ -> exprParser)
        |. P.spaces
        |= P.lazy (\_ -> exprParser)
        |. P.spaces
        |. P.symbol ")"


defineParser : P.Parser Expr
defineParser =
    P.succeed Define
        |. P.symbol "(define "
        |. P.spaces
        |= P.lazy (\_ -> exprParser)
        |. P.spaces
        |= P.lazy (\_ -> exprParser)
        |. P.spaces
        |. P.symbol ")"


lambdaParser : P.Parser Expr
lambdaParser =
    P.succeed Lambda
        |. P.symbol "(lambda "
        |. P.spaces
        |= P.lazy (\_ -> listParser)
        |. P.spaces
        |= P.lazy (\_ -> exprParser)
        |. P.spaces
        |. P.symbol ")"


listParser : P.Parser Expr
listParser =
    P.succeed L
        |. P.symbol "("
        |= many exprParser
        |. P.symbol ")"


intParser : P.Parser Expr
intParser =
    P.map Z P.int


floatParser : P.Parser Expr
floatParser =
    P.map F P.float

negativeFloatParser : P.Parser Expr
negativeFloatParser =
   P.succeed F
     |. P.symbol "-"
     |= (P.float |> P.map (\x -> -x))

negativeIntParser : P.Parser Expr
negativeIntParser =
   P.succeed Z
     |. P.symbol "-"
     |= (P.int |> P.map (\z -> -z))

stringParser : P.Parser Expr
stringParser =
    let
        prefix : Char -> Bool
        prefix =
            \c -> not <| List.member c [ '(', ')', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' ]

        continue : Char -> Bool
        continue =
            \c -> not <| List.member c [ ' ', ')' ]
    in
    text prefix continue |> P.map Str



-- HELPERS


text : (Char -> Bool) -> (Char -> Bool) -> P.Parser String
text prefix continue =
    P.succeed (\start finish content -> String.slice start finish content)
        |= P.getOffset
        |. P.chompIf (\c -> prefix c)
        |. P.chompWhile (\c -> continue c)
        |= P.getOffset
        |= P.getSource


{-| Apply a parser zero or more times and return a list of the results.
-}
many : P.Parser a -> P.Parser (List a)
many p =
    P.loop [] (manyHelp p)


manyHelp : P.Parser a -> List a -> P.Parser (P.Step (List a) (List a))
manyHelp p vs =
    P.oneOf
        [ P.succeed (\v -> P.Loop (v :: vs))
            |= p
            |. P.spaces
        , P.succeed ()
            |> P.map (\_ -> P.Done (List.reverse vs))
        ]
