-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Cambiatus.Union.NotificationType exposing (..)

import Cambiatus.InputObject
import Cambiatus.Interface
import Cambiatus.Object
import Cambiatus.Scalar
import Cambiatus.ScalarCodecs
import Cambiatus.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (FragmentSelectionSet(..), SelectionSet(..))
import Json.Decode as Decode


type alias Fragments decodesTo =
    { onMint : SelectionSet decodesTo Cambiatus.Object.Mint
    , onOrder : SelectionSet decodesTo Cambiatus.Object.Order
    , onTransfer : SelectionSet decodesTo Cambiatus.Object.Transfer
    }


{-| Build up a selection for this Union by passing in a Fragments record.
-}
fragments :
    Fragments decodesTo
    -> SelectionSet decodesTo Cambiatus.Union.NotificationType
fragments selections =
    Object.exhaustiveFragmentSelection
        [ Object.buildFragment "Mint" selections.onMint
        , Object.buildFragment "Order" selections.onOrder
        , Object.buildFragment "Transfer" selections.onTransfer
        ]


{-| Can be used to create a non-exhaustive set of fragments by using the record
update syntax to add `SelectionSet`s for the types you want to handle.
-}
maybeFragments : Fragments (Maybe decodesTo)
maybeFragments =
    { onMint = Graphql.SelectionSet.empty |> Graphql.SelectionSet.map (\_ -> Nothing)
    , onOrder = Graphql.SelectionSet.empty |> Graphql.SelectionSet.map (\_ -> Nothing)
    , onTransfer = Graphql.SelectionSet.empty |> Graphql.SelectionSet.map (\_ -> Nothing)
    }
