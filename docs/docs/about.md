# Elm-MicroScheme

Elm-Microscheme is an implementation of a tiny
subset of Scheme written in [Elm](https://elm-lang.org).
Since the aim of the project is educational — to underestand
how to build a Scheme interpreter — I intend to 
keep the codebase very small. A good exercise is to 
fork the project and 
add whatever features to it that you find interesting
or useful.


## Directions

To compile and run the interpreter, say `sh run.sh` 
on the command line.  This command will compile 
the code and start up the command-line interface
to the interpreter.  Below is a screenshot of the
a short session with the interpreter. 



![Running Interpreter](https://imagedelivery.net/9U-0Y4sEzXlO6BXzTnQnYQ/f4b24389-ee90-4bbb-285e-262d0912d500/public)


## Layout of the code


```text
----------------------------------------------------------------------------------
File                                           blank        comment           code
----------------------------------------------------------------------------------
src/MicroScheme/Eval.elm                          42             10            100
src/MicroScheme/Environment.elm                   29              1             74
src/MicroScheme/Parser.elm                        28             11             56
src/Main.elm                                      22              1             38
src/MicroScheme/Interpreter.elm                   16             14             38
src/MicroScheme/Examples.elm                      18              1             16
src/MicroScheme/Expr.elm                           4              0             13
----------------------------------------------------------------------------------
SUM:                                             159             38            335
----------------------------------------------------------------------------------
```

## Structure of the Project

