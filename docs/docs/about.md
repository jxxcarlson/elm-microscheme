# Elm-MicroScheme

Elm-Microscheme is an implementation of a tiny
subset of Scheme written in [Elm](https://elm-lang.org).
Since the aim of the project is educational — to understand
how to build a Scheme interpreter — I intend to 
keep the codebase very small even as I work to 
add new features, e.g., a proper treatment
of environments. A good exercise is to 
fork the project and 
add whatever features to it that you find interesting
or useful.

This project is open-source, with the code
on [GitHub](https://github.com/jxxcarlson/elm-microscheme).

## Directions

To compile and run the interpreter, say `sh run.sh` 
on the command line.  This command will compile 
the code and start up the command-line interface
to the interpreter.  Below is a screenshot of 
a short session with the interpreter. 



![Running Interpreter](https://imagedelivery.net/9U-0Y4sEzXlO6BXzTnQnYQ/7bb38caa-c314-48f0-6626-a90140b12c00/public
)

A good place to check whether microScheme is doing the
right thing is [try.scheme.org](https://try.scheme.org/).
I use it all the time to help correct my mistakes.

## Layout of the code


```text
----------------------------------------------------------------------------------
File                                           blank        comment           code
----------------------------------------------------------------------------------
src/MicroScheme/Parser.elm                        40             16            115
src/MicroScheme/Numbers.elm                       45              1            107
src/MicroScheme/Function.elm                      40              0            103
src/MicroScheme/Eval.elm                          33             13             94
src/MicroScheme/Interpreter.elm                   37             26             83
src/MicroScheme/Frame.elm                         29              0             73
src/MicroScheme/Environment.elm                   21              1             53
src/Main.elm                                      22              0             41
src/MicroScheme/Init.elm                           7              0             22
src/repl.js                                        8              4             19
src/MicroScheme/Expr.elm                           2              0             12
src/MicroScheme/Error.elm                          3              0              5
----------------------------------------------------------------------------------
SUM:                                             287             61            727
----------------------------------------------------------------------------------
```






