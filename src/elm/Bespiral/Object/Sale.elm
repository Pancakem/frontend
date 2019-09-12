-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Bespiral.Object.Sale exposing (communityId, createdAt, createdBlock, createdEosAccount, createdTx, creator, creatorId, description, id, image, price, title, trackStock, units)

import Bespiral.InputObject
import Bespiral.Interface
import Bespiral.Object
import Bespiral.Scalar
import Bespiral.ScalarCodecs
import Bespiral.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


communityId : SelectionSet String Bespiral.Object.Sale
communityId =
    Object.selectionForField "String" "communityId" [] Decode.string


createdAt : SelectionSet Bespiral.ScalarCodecs.DateTime Bespiral.Object.Sale
createdAt =
    Object.selectionForField "ScalarCodecs.DateTime" "createdAt" [] (Bespiral.ScalarCodecs.codecs |> Bespiral.Scalar.unwrapCodecs |> .codecDateTime |> .decoder)


createdBlock : SelectionSet Int Bespiral.Object.Sale
createdBlock =
    Object.selectionForField "Int" "createdBlock" [] Decode.int


createdEosAccount : SelectionSet String Bespiral.Object.Sale
createdEosAccount =
    Object.selectionForField "String" "createdEosAccount" [] Decode.string


createdTx : SelectionSet String Bespiral.Object.Sale
createdTx =
    Object.selectionForField "String" "createdTx" [] Decode.string


creator : SelectionSet decodesTo Bespiral.Object.Profile -> SelectionSet decodesTo Bespiral.Object.Sale
creator object_ =
    Object.selectionForCompositeField "creator" [] object_ identity


creatorId : SelectionSet String Bespiral.Object.Sale
creatorId =
    Object.selectionForField "String" "creatorId" [] Decode.string


description : SelectionSet String Bespiral.Object.Sale
description =
    Object.selectionForField "String" "description" [] Decode.string


id : SelectionSet Int Bespiral.Object.Sale
id =
    Object.selectionForField "Int" "id" [] Decode.int


image : SelectionSet (Maybe String) Bespiral.Object.Sale
image =
    Object.selectionForField "(Maybe String)" "image" [] (Decode.string |> Decode.nullable)


price : SelectionSet String Bespiral.Object.Sale
price =
    Object.selectionForField "String" "price" [] Decode.string


title : SelectionSet String Bespiral.Object.Sale
title =
    Object.selectionForField "String" "title" [] Decode.string


trackStock : SelectionSet Bool Bespiral.Object.Sale
trackStock =
    Object.selectionForField "Bool" "trackStock" [] Decode.bool


units : SelectionSet Int Bespiral.Object.Sale
units =
    Object.selectionForField "Int" "units" [] Decode.int