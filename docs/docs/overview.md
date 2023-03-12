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
parse : Dict String Expr -> String -> Result (List P.DeadEnd) Expr
parse table str =
    P.run exprParser str |> Result.map (Environment.applyFrame table)
```