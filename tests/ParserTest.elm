module ParserTest exposing (evalSuite, parserSuite)

import Expect
import MicroScheme.Environment as Environment
import MicroScheme.Expr exposing (Expr(..))
import MicroScheme.Frame as Frame
import MicroScheme.Init exposing (rootFrame)
import MicroScheme.Interpreter as Interpreter
import MicroScheme.Parser exposing (parse)
import Parser exposing (DeadEnd)
import Test exposing (Test, describe, test)


parseTest : String -> Result (List DeadEnd) Expr -> Test
parseTest input output =
    test input <|
        \_ ->
            Expect.equal (parseAndResolve input) output


parseAndResolve : String -> Result (List DeadEnd) Expr
parseAndResolve input =
    input |> parse |> Result.map (Frame.resolve [] rootFrame)


progTest : String -> String -> Test
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
        , parseTest "(define (square x) (* x x))" (Ok (Define (L [ Str "square", Str "x" ]) (L [ Sym "*", Str "x", Str "x" ])))
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
        , progTest "(cons 2 3)" "(2 . 3)"
        , progTest "(cons 1 (quote (2 3)))" "(1 2 3)"
        , progTest "(car (quote 1 2 3))" "1"
        , progTest "(cdr (quote 1 2 3))" "(2 3)"
        , progTest "(car (cdr (quote 1 2 3)))" "2"
        , progTest "(cdr (cdr (quote 1 2 3)))" "(3)"
        , progTest "(cons 1 (list (2 3)))" "(1 (2 3))"
        , progTest "(car (list 1 2 3))" "1"
        , progTest "(cdr (list 1 2 3))" "(2 3)"
        , progTest "(car (cdr (list 1 2 3)))" "2"
        , progTest "(cdr (cdr (list 1 2 3)))" "(3)"
        , progTest "(define (inc x) (+ 1 x)); (map inc (list 1 2 3))" "(2 3 4)"
        , progTest "((Lambda (x) (* x x)) 2)" "4"
        , progTest "(map (Lambda (x) (* x x)) (list 1 2 3 4))" "(1 4 9 16)"
        , progTest "(if (< 0 1) A B)" "A"
        , progTest "(roundTo 2 1.2345)" "1.23"
        , progTest "(remainder 3 2)" "1"
        ]
