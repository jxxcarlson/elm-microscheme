module MicroScheme.Environment exposing
    ( Environment
    , current
    , initial
    , root
    )

import MicroScheme.Frame as Frame exposing (Frame)
import Tree exposing (Tree)
import Tree.Zipper exposing (Zipper)


type alias Environment =
    Zipper Frame


initial =
    Tree.Zipper.fromTree (Tree.singleton Frame.empty)


root : Environment -> Frame
root environment =
    current (Tree.Zipper.root environment)


current : Environment -> Frame
current environment =
    Tree.Zipper.label environment
