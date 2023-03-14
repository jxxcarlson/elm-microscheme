# Function List


## Scheme


### Data

- 

### Function Examples

### Define

``
> (define x 3)
```
- `(define (isEven n) (= (remainder n 2) 0))`
- `(if (< 0 1) "A" "B")`



## Function Dictionary

```elm
functionDict : Dict String (List Expr -> Result EvalError Expr)
functionDict =
    Dict.fromList
        [ ( "+", evalPlus )
        , ( "*", evalTimes )
        , ( "roundTo", roundTo )
        , ( "=", equalNumbers )
        , ( "<", ltPredicate )
        , ( ">", gtPredicate )
        , ( "<=", ltePredicate )
        , ( ">=", gtePredicate )
        , ( "remainder", remainder )
        ]
```

## Arithmetic

- `(+ 1 2 3 4) => 10`

- `(* 1 2 3 4) => 24`

- `(roundTo 2 3.1416) => 3.14`

- `(= 2 3) => False`

- `(< 2 3) => True`

- `(<= 2 3) => True`

- `(> 2 3) => False`

- `(>=2 3) => False`

- `(remainder 15 2) => 1`