module MicroScheme.Parser exposing (exprParser, parse)

import Dict exposing (Dict)
import MicroScheme.Expr as Expr exposing (Expr(..))
import MicroScheme.Frame as Frame exposing (Frame)
import Parser as P exposing ((|.), (|=))
import Set


{-|

    > parse symbolTable "(plus 33 44)"
    Ok (L [Sym "plus",Z 33,Z 44])

    > newSymbolTable = addSymbol "x" (Sym "x") symbolTable
    Dict.fromList [("plus",Sym "plus"),("times",Sym "times"),("x",Sym "x")]

    > parse newSymbolTable "(plus x 2)"
    Ok (L [Sym "plus",Sym "x",Z 2])

-}
parse : Frame -> String -> Result (List P.DeadEnd) Expr
parse frame str =
    P.run exprParser str |> Result.map (Frame.resolve frame)


exprParser : P.Parser Expr
exprParser =
    P.oneOf
        [ specialFormParser
        , P.lazy (\_ -> listParser)
        , P.backtrackable intParser
        , floatParser
        , stringParser
        ]


specialFormParser =
    P.oneOf [ P.map SF defineParser ]


defineParser : P.Parser Expr.SpecialForm
defineParser =
    P.map (\_ -> Expr.Define) (P.symbol "define")


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


stringParser : P.Parser Expr
stringParser =
    P.map Str
        (P.variable
            { start = \c -> Char.isAlpha c || c == '+' || c == '*'
            , inner = \c -> Char.isAlphaNum c || c == '_'
            , reserved = Set.fromList [ "eval", "define", "display" ]
            }
        )



-- HELPERS


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
