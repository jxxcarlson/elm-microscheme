module MicroScheme.Environment exposing
    ( SymbolTable
    , addSymbol
    , resolveSymbols
    , symbolTable
    )

import Dict exposing (Dict)
import MicroScheme.Expr exposing (Expr(..))


type alias SymbolTable =
    Dict String Expr


symbolTable : Dict String Expr
symbolTable =
    Dict.fromList
        [ ( "plus", Sym "plus" )
        , ( "times", Sym "times" )
        ]


addSymbol : String -> Expr -> SymbolTable -> SymbolTable
addSymbol str expr table =
    Dict.insert str expr table


resolveSymbols : Dict String Expr -> Expr -> Expr
resolveSymbols table expr =
    case expr of
        Str s ->
            case Dict.get s table of
                Nothing ->
                    expr

                Just expr2 ->
                    expr2

        L list ->
            L (List.map (resolveSymbols table) list)

        _ ->
            expr
