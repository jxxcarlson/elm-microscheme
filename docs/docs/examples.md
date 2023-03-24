# Examples


## Scheme

### Constructors and destructors

```text
> (cons 4 5)
(4 . 5)

> (cons 1 (quote (2 3)))
(1 2 3)

> (cons (+ 1 2 3) 5)
(6 . 5)

> (cons (quote (+ 1 2 3)) 5)
((+ 1 2 3) . 5)

> (list 1 2 3)
(1 2 3)

> (cons 0 (list 1 2 3))
(0 1 2 3)

> (car (list 1 2 3))
1

> (car (quote (1 2 3))
1

> (cdr (list 1 2 3))
(2 3)

> (cdr (quote (1 2 3)))
(2 3)
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

### Higher order

```text
> (define (inc x) (+ 1 x))
inc

> (map inc (list 1 2 3))
(2 3 4)
```


### Lambda

```text
> ((Lambda (x) (* x x)) 2)
4

> (map (Lambda (x) (* x x)) (list 1 2 3 4))
(1 4 9 16)
```

### If

```text
> (if (< 0 1) A B)
A
```

### Environment

You can look up values in the environment:

```
> (lookup square)
[Lambda (L [Str "x"]) (L [Sym "*",Str "x",Str "x"])]
```

You can turn debugging on and off:

```text
    Debug
    -----

    > (+ 1 2)
    3
    > debug
      true
    > (+ 1 2)
    PARSE: Ok (L [Sym "+",Z 1,Z 2])
    3
    > debug
    PARSE: Ok (Sym "debug")
    false
    > (+ 1 2)
    3
```

Something slightly more complex:

```
> (define (isEven n) (= (remainder n 2) 0))
isEven

> (isEven 17)
False
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