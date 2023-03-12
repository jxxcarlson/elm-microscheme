module MicroScheme.Environment exposing
    ( Frame
    , FrameError(..)
    , SymbolTable
    , addBinding
    , addBindings
    , addSymbol
    , applyFrame
    , emptyFrame
    , symbolTable
    , varNames
    )

import Dict exposing (Dict)
import Maybe.Extra
import MicroScheme.Expr exposing (Expr(..))


{-| -}
type alias Frame =
    Dict String Expr


emptyFrame =
    Dict.empty


addBinding : ( String, Expr ) -> Frame -> Frame
addBinding ( str, expr ) frame =
    Dict.insert str expr frame


type FrameError
    = UnequalLists Int Int


addBindings : List String -> List Expr -> Frame -> Result FrameError Frame
addBindings vars exprs frame =
    let
        nVars =
            List.length vars

        nExprs =
            List.length exprs
    in
    if nVars /= nExprs then
        Err (UnequalLists nVars nExprs)

    else
        let
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


type alias SymbolTable =
    Dict String Expr


symbolTable : Dict String Expr
symbolTable =
    Dict.fromList
        [ ( "+", Sym "+" )
        , ( "*", Sym "*" )
        ]


addSymbol : String -> Expr -> SymbolTable -> SymbolTable
addSymbol str expr table =
    Dict.insert str expr table


applyFrame : Frame -> Expr -> Expr
applyFrame frame expr =
    case expr of
        Str s ->
            case Dict.get s frame of
                Nothing ->
                    expr

                Just expr2 ->
                    expr2

        L list ->
            L (List.map (applyFrame frame) list)

        _ ->
            expr
