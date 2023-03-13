module ParserTest exposing (..)

import Expect exposing (Expectation)
import MicroScheme.Expr exposing (Expr(..))
import MicroScheme.Init exposing (rootFrame)
import MicroScheme.Parser exposing (parse)
import Test exposing (..)


p =
    parse rootFrame


parseTest input output =
    test input <|
        \_ ->
            Expect.equal (p input) output


suite : Test
suite =
    describe "The Parser module"
        [ parseTest "1" (Ok (Z 1))
        , parseTest "1.2" (Ok (F 1.2))
        , parseTest "(1 2)" (Ok (L [ Z 1, Z 2 ]))
        , parseTest "(remainder 3 2)" (Ok (L [ Sym "remainder", Z 3, Z 2 ]))
        , parseTest "(< 3 4)" (Ok (L [ Sym "<", Z 3, Z 4 ]))
        , parseTest "(= 3 4)" (Ok (L [ Sym "=", Z 3, Z 4 ]))
        , parseTest "(define a 5)" (Ok (Define (Str "a") (Z 5)))
        , parseTest "(define (square x) (* x x))" (Ok (Define (L [ Str "square", Str "x" ]) (L [ Str "*", Str "x", Str "x" ])))
        , parseTest "(lambda (x y) (* x y))" (Ok (Lambda (L [ Str "x", Str "y" ]) (L [ Str "*", Str "x", Str "y" ])))
        , parseTest "(if (> a 0) 1 -1)" (Ok (If (L [ Str ">", Str "a", Z 0 ]) (Z 1) (Str "-1")))
        ]
