module MicroScheme.Environment exposing
    ( Environment
    , empty
    )

import MicroScheme.Frame as Frame exposing (Frame)
import Tree exposing (Tree)
import Tree.Zipper exposing (Zipper)


type alias Environment =
    Zipper Frame


empty =
    Tree.Zipper.fromTree (Tree.singleton Frame.empty)
