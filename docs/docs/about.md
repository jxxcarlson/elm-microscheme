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



![Running Interpreter](https://imagedelivery.net/9U-0Y4sEzXlO6BXzTnQnYQ/44526732-a41a-4f69-54a5-82785d9cbd00/public)


## Layout of the code


```text
----------------------------------------------------------------------------------
File                                           blank        comment           code
----------------------------------------------------------------------------------
src/MicroScheme/Eval.elm                          40             10             93
src/MicroScheme/Frame.elm                         25              0             64
src/MicroScheme/Parser.elm                        28             11             56
src/MicroScheme/Interpreter.elm                   18             14             43
src/Main.elm                                      22              0             41
src/MicroScheme/Environment.elm                    9              0             20
src/MicroScheme/Examples.elm                      18              1             16
src/MicroScheme/Expr.elm                           4              0             13
src/MicroScheme/Init.elm                           3              0             10
----------------------------------------------------------------------------------
SUM:                                             167             36            356
----------------------------------------------------------------------------------
```

## Structure of the Project

