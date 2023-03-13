# Notes

## Minimal Scheme

```lisp
quote
if
lambda
define
set!
begin
cons
car
cdr
null?
```

A somewhat longer list:

```lisp
lambda - Defines a new anonymous procedure.

define - Defines a named procedure or value.

if - Conditional expression that evaluates one of two expressions based on a condition.

let - Defines a new variable within a local scope.

let* - Like let, but allows defining variables that depend on each other.

letrec - Like let, but allows defining mutually recursive variables.

set! - Assigns a new value to an existing variable.

begin - Evaluates a sequence of expressions in order and returns the result of the last expression.

quote - Returns a given expression without evaluating it.

list - Constructs a list of its arguments.

cons - Constructs a new pair.

car - Returns the first element of a pair.

cdr - Returns the second element of a pair.

null? - Returns #t if the argument is the empty list.

eq? - Returns #t if two arguments are the same object in memory.

equal? - Returns #t if two arguments are structurally equivalent.

map - Applies a given procedure to each element of a list and returns a new list of the results.

fold (also known as reduce) - Applies a given procedure to a list, starting with an initial value, and accumulates the results.

filter - Returns a new list containing only the elements of a given list that satisfy a given predicate.

cond - A more flexible version of if that allows evaluating multiple expressions based on different conditions.

and - Evaluates a sequence of expressions and returns #f if any of them evaluate to #f.

or - Evaluates a sequence of expressions and returns #t if any of them evaluate to #t.

not - Returns the logical negation of its argument.

apply - Calls a procedure with a list of arguments
```