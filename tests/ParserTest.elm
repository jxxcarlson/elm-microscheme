module ParserTest exposing (evalSuite, parserSuite)

import Expect exposing (Expectation)
import MicroScheme.Expr exposing (Expr(..))
import MicroScheme.Init exposing (rootFrame)
import MicroScheme.Interpreter as Interpreter
import MicroScheme.Parser exposing (parse)
import Test exposing (..)


parseTest input output =
    test input <|
        \_ ->
            Expect.equal (parse rootFrame input) output


progTest input output =
    test input <|
        \_ ->
            Expect.equal (Interpreter.runProgram ";" input) output


parserSuite : Test
parserSuite =
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


evalSuite : Test
evalSuite =
    describe "The Interpreter and Eval module"
        [ progTest "1" "1"
        , progTest "(define a 5); a" "5"
        , progTest "(+ 1 2)" "3"
        , progTest "(* (+ 1 2) (+ 3 4))" "21"
        , progTest "(define (square x) (* x x)); (square (square 6))" "1296"
        , progTest "(< 0 1)" "True"
        , progTest "(< 1 0)" "False"
        , progTest "(if (< 0 1) \"A\" \"B\")" "\"A\""
        , progTest "(define (isEven n) (= (remainder n 2) 0)); (isEven 6)" "True"
        ]
