module MicroScheme.Frame exposing
    ( Bindings
    , Frame
    , FrameError(..)
    , FrameId
    , addBinding
    , addBindings
    , addSymbol
    , empty
    , resolve
    , varNames
    )

import Dict exposing (Dict)
import Maybe.Extra
import MicroScheme.Expr exposing (Expr(..))


type alias Frame =
    { id : FrameId
    , bindings : Bindings
    }


type alias FrameId =
    Int


type alias Bindings =
    Dict String Expr


type FrameError
    = UnequalLists Int Int


empty : { id : number, bindings : Dict k v }
empty =
    { id = -1
    , bindings = Dict.empty
    }


addBinding : ( String, Expr ) -> Frame -> Frame
addBinding ( str, expr ) frame =
    { frame | bindings = Dict.insert str expr frame.bindings }


addBindings : List String -> List Expr -> Frame -> Result FrameError Frame
addBindings vars exprs frame =
    let
        nVars : Int
        nVars =
            List.length vars

        nExprs : Int
        nExprs =
            List.length exprs
    in
    if nVars /= nExprs then
        Err (UnequalLists nVars nExprs)

    else
        let
            bindings : List ( String, Expr )
            bindings =
                List.map2 (\a b -> ( a, b )) vars exprs
        in
        Ok (List.foldl addBinding frame bindings)


varNames : List Expr -> List String
varNames exprs =
    exprs |> List.map varName |> Maybe.Extra.values


varName : Expr -> Maybe String
varName expr =
    case expr of
        Str s ->
            Just s

        _ ->
            Nothing


addSymbol : String -> Expr -> Frame -> Frame
addSymbol str expr frame =
    { frame | bindings = Dict.insert str expr frame.bindings }


resolve : List String -> Frame -> Expr -> Expr
resolve exceptions frame expr =
    case expr of
        Str s ->
            case Dict.get s frame.bindings of
                Nothing ->
                    expr

                Just expr2 ->
                    if List.member s exceptions then
                        expr

                    else
                        expr2

        L list ->
            L (List.map (resolve exceptions frame) list)

        Define expr1 expr2 ->
            Define expr1 (resolve exceptions frame expr2)

        _ ->
            expr
