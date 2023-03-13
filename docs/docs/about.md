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


## Layout of the code


```text
----------------------------------------------------------------------------------
File                                           blank        comment           code
----------------------------------------------------------------------------------
src/MicroScheme/Numbers.elm                       45              1            107
src/MicroScheme/Frame.elm                         29              0             73
src/MicroScheme/Interpreter.elm                   33             20             66
src/MicroScheme/Parser.elm                        28             11             55
src/MicroScheme/Environment.elm                   19              0             48
src/MicroScheme/Eval.elm                          20             11             47
src/MicroScheme/Function.elm                      17              0             45
src/Main.elm                                      22              0             41
src/repl.js                                        8              4             19
src/MicroScheme/Expr.elm                           4              0             13
src/MicroScheme/Init.elm                           7              0             13
src/MicroScheme/Error.elm                          3              0              5
----------------------------------------------------------------------------------
SUM:                                             235             47            532
```






