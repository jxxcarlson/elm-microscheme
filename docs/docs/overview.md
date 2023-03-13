# Overview

## Expr Type

The Expr type is define in module `Expr`:

```elm
type Expr
    = Z Int
    | F Float
    | Str String
    | Sym String
    | L (List Expr)
    | SF SpecialForm


type SpecialForm
    = Define
    | Lambda
    | Display
    | If
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
eval : Expr -> Result EvalError Expr
```

It calls `evalResult`, which is a long exercise
in pattern-matching:

```elm
evalResult : Result EvalError Expr -> Result EvalError Expr
evalResult resultExpr =
    case resultExpr of
        Err error ->
            Err error

        Ok expr ->
            case expr of
                Z n ->
                    Ok (Z n)

                F r ->
                    Ok (F r)

                Sym s ->
                    Ok (Sym s)

                L ((Sym name) :: rest) ->
                    case Function.dispatch name of
                        Err _ ->
                            Err (EvalError 3 ("dispatch " ++ name ++ " did not return a value"))

                        Ok f ->
                            Result.map f (evalArgs rest) |> Result.Extra.join

                L ((L ((SF Lambda) :: (L params) :: (L body) :: [])) :: args) ->
                    applyLambda params body args |> evalResult

                _ ->
                    Err <| EvalError 0 "Missing case (eval)"
```

In the above code, `Function.dispatch` takes a function name as input
and produces a value of type
`Result EvalError (List Expr -> Result EvalError Expr)`
as output.
The function `evalArgs` evaluates the arguments of
the function called:

```elm
evalArgs : List Expr -> Result EvalError (List Expr)
evalArgs args =
    List.map (evalResult << Ok) args |> Result.Extra.combine
```

The function `applyLambda`  creates a temporary frame with
bindings for the variable names and arguments of the 
lambda expression, then uses that frame to
resolve the names which appear in the function
body.

```elm
applyLambda : List Expr -> List Expr -> List Expr -> Result EvalError Expr
applyLambda params body args =
    let
        frameResult : Result Frame.FrameError Frame.Frame
        frameResult =
            Frame.addBindings (Frame.varNames params) args Frame.empty
    in
    case frameResult of
        Err frameError ->
            Err frameError |> Result.mapError (\err -> FR err)

        Ok frame ->
            Ok (List.map (Frame.resolve frame) body |> L)
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
`NumberErrot` and the functions `coerce` and `roundTo`.

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
`x` rounded to two dedicmals.