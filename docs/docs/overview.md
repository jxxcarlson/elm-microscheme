# Overview

## Expr Type

The Expr type is define in module `Expr`:

```elm

type Expr
    = Z Int
    | F Float
    | B Bool
    | Str String
    | Sym String
    | L (List Expr)
    | Pair Expr Expr
    | Lambda Expr Expr
    | Define Expr Expr
    | If Expr Expr Expr

```

## Parser


```text
parse : Frame -> String -> Result (List P.DeadEnd) Expr
parse table str =
    P.run exprParser str |> Result.map (Environment.applyFrame table)
```

The first argument of `parse` is the root frame, which
is used to map certain values to symbols, e.g.,
`Str "+"` to `Sym "+"`.  Thus we have

```elm
> import MicroScheme.Parser exposing(parse)
> import MicroScheme.Init exposing(rootFrame)

> parse rootFrame "(+ 1 2)"
Ok (L [Sym "+",Z 1,Z 2])

```

## Eval

The module `Eval` exports just one function,

```elm
eval : Environment -> Expr -> Result EvalError Expr
eval env expr =
    evalResult env (Ok expr)
```

It calls `evalResult`, which is a long exercise
in pattern-matching:

```elm
evalResult : Environment -> Result EvalError Expr -> Result EvalError Expr
evalResult env resultExpr =
    case resultExpr of
        Err error ->
            Err error

        Ok expr ->
            case expr of
                Z n ->
                    Ok (Z n)

                F x ->
                    Ok (F x)

                Sym s ->
                    Ok (Sym s)

                L ((Sym functionName) :: args) ->
                    dispatchFunction env functionName args

                L ((Lambda (L params) (L body)) :: args) ->
                    evalResult env (applyLambdaToExpressionList params body args)

                L ((Lambda (L params) body) :: args) ->
                    evalResult env (applyLambdaToExpression params body args)

                If (L boolExpr_) expr1 expr2 ->
                    evalBoolExpr env boolExpr_ expr1 expr2

                L ((Str name) :: rest) ->
                    Err <| EvalError 0 ("Unknown symbol: " ++ name)

                L exprList_ ->
                    Err <| EvalError -1 <| "!!! "

                _ ->
                    Err <| EvalError 0 <| "Missing case (eval), expr = XXX"
```


Function `evalResult` matches the various patterns presented by
`expr`, mapping them to handlers which act on various subexpressions, returning a value of 
type `Result EvalError Expr`.  An example, the pattern
`L ((Sym functionName) :: args)` is handle by the function call
`dispatchFunction env functionName args`, which operates by 
evaluating `arg` using the environment `env`, then applying
the function of type `List Expr -> Result EvalError Expr` that it finds for the key `functionName`
in a suitable dictionary.

One more example: the function `applyLambdaToExpressionList`  creates a temporary frame with
bindings for the variable names and arguments of the 
lambda expression, then uses that frame to
resolve the names which appear in the function
body.  The result of this operation is then evaluated in the 
current environment by `evalResult`.

```elm
applyLambdaToExpressionList : List Expr -> List Expr -> List Expr -> Result EvalError Expr
applyLambdaToExpressionList params body args =
    let
        -- `A throw-away frame. It will never be used
        -- outside of this function.
        frameResult : Result Frame.FrameError Frame.Frame
        frameResult =
            Frame.addBindings (Frame.varNames params) args Frame.empty
    in
    case frameResult of
        Err frameError ->
            Err frameError |> Result.mapError (\err -> FR err)

        Ok frame ->
            Ok (List.map (Frame.resolve frame) body |> L)        Ok (List.map (Frame.resolve frame) body |> L)
```
The `Function` module exports built-in functions for
use by `eval`, e.g., `Function.plus` and `Function.times`.
To add a new function to MicroScheme, add an 
implementation of it to module `Function` and add its
name to `symbolStrings` in module `Init`.


## Interpreter

The interpreter is governed by the three functions

```elm
init : State
input : String -> State -> State
step : State -> State
```

where

```elm
type alias State =
    { input : String
    , output : String
    , environment : Environment
    }
```

The function `init` returns a state in which
the input and output fields are empty strings
and the environment is a tree with one node, 
the `rootFrame`.  The root frame holds a dictionary
that maps strings to symbols, e.g., "+" to `Sym "+"`.

The function `input` accepts a strings and sets the
field `input` to it.

The function `step` runs the parse on `input`, 
runs `eval` on the result, and puts a string
version of the result in `output`.

## Frames and Environments


A *frame* binds expressions to names:

```elm
type alias Frame =
    { id : FrameId
    , bindings : Bindings
    }


type alias FrameId =
    Int


type alias Bindings =
    Dict String Expr
```

An *environment* is a tree of frames with a distinguished
(movable) node, i.e., a zipper:

```elm
type alias Environment =
    Zipper Frame
```

## Numbers

Module `Numbers` exports the type
`NumberError` and the functions `coerce` and `roundTo`.

```elm
coerce : List Expr -> Result NumberError (Either (List Int) (List Float))
```

- If the argument of `coerce` is a list of `Z Int`,
it returns  a `Left (List Int)` value.  

- If it is 
a list o `F Float`, it returns a value of type
`Right (List Float)`.  

- If it is a list of values of types
`Z Int` and `F Float`, it coerces the values 
of type `Z Int`to `Z Float` and returns a value
of type `Right (List Float)`. 

- In all other cases it return `Left NotAllNumbers`

The function call `roundTo 2 x` returns the value 
`x` rounded to two decicmals.


**Examples**

*No coercion:*

```text
> (+ 1 2)
3

> (+ 1.003 2)
3.003

> (+ 1.003 2.7)
3.7030000000000003
```

In the last case, floating point arithmetic produces
an incorrect result.  Better looking is the below

```text
> (roundTo 2 (+ 1.003 2.7))
3.7
```

*Coercion:*

```text
> (+ 1.1 2)
3.1
```

