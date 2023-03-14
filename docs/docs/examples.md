# Examples


## Scheme

### Constructors

```text
> (cons (+ 1 2 3) 5)
(6 . 5)

> (cons (quote (+ 1 2 3)) 5)
((+ 1 2 3) . 5)
```


### Define

``` 
> (define x 3)
x

> x
3

> (define (square x) (* x x))
square

> (square 4)
16
```

Notice that you can look up values in the environment:

```
> (lookup square)
[Lambda (L [Str "x"]) (L [Sym "*",Str "x",Str "x"])]
```

Something slightly more complex:

```
> (define (isEven n) (= (remainder n 2) 0))
isEven

> (isEven 17)
False
```

### If

```text
> (if (< 0 1) A B)
A
```


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