module Community exposing (Action, Balance, Community, CreateCommunityData, DashboardInfo, Metadata, Objective, ObjectiveId, Transaction, Validator, Verification(..), Verifiers, WithObjectives, communitiesQuery, communityQuery, createCommunityData, decodeBalance, decodeObjectiveId, decodeTransaction, encodeCreateActionAction, encodeCreateCommunityData, encodeCreateObjectiveAction, encodeObjectiveId, encodeUpdateLogoData, logoBackground, logoTitleQuery, logoUrl)

import Account exposing (Profile, accountSelectionSet)
import Api.Relay exposing (MetadataConnection, PaginationArgs)
import Bespiral.Enum.VerificationType exposing (VerificationType(..))
import Bespiral.Object
import Bespiral.Object.Action as Action
import Bespiral.Object.Community as Community
import Bespiral.Object.Objective as Objective
import Bespiral.Object.Validator
import Bespiral.Query as Query
import Bespiral.Scalar exposing (DateTime(..))
import Eos exposing (EosBool(..), Symbol, symbolToString)
import Eos.Account as Eos
import Graphql.Operation exposing (RootQuery)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Html exposing (Html)
import Html.Attributes
import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline as Decode exposing (required)
import Json.Encode as Encode exposing (Value)
import Time exposing (Posix)
import Transfer exposing (ConnectionTransfer, Transfer, metadataConnectionSelectionSet, transferConnectionSelectionSet)
import Utils



-- DashboardInfo for Dashboard


type alias DashboardInfo =
    { title : String
    , logo : String
    , members : List Profile
    }



-- METADATA
-- Used on community listing


type alias Metadata =
    { title : String
    , description : String
    , symbol : Symbol
    , logo : String
    , creator : Eos.Name
    , transfers : Maybe MetadataConnection
    , memberCount : Int
    }


type alias Community =
    { title : String
    , description : String
    , symbol : Symbol
    , logo : String
    , creator : Eos.Name
    , memberCount : Int
    , members : List Profile
    , transfers : Maybe ConnectionTransfer
    , objectives : List Objective
    }



-- GraphQL


communitiesSelectionSet : (PaginationArgs -> PaginationArgs) -> SelectionSet Metadata Bespiral.Object.Community
communitiesSelectionSet paginateArgs =
    SelectionSet.succeed Metadata
        |> with Community.name
        |> with Community.description
        |> with (Eos.symbolSelectionSet Community.symbol)
        |> with Community.logo
        |> with (Eos.nameSelectionSet Community.creator)
        |> with
            (Community.transfers
                paginateArgs
                metadataConnectionSelectionSet
            )
        |> with Community.memberCount


dashboardSelectionSet : SelectionSet DashboardInfo Bespiral.Object.Community
dashboardSelectionSet =
    SelectionSet.succeed DashboardInfo
        |> with Community.name
        |> with Community.logo
        |> with (Community.members accountSelectionSet)


communitySelectionSet : (PaginationArgs -> PaginationArgs) -> SelectionSet Community Bespiral.Object.Community
communitySelectionSet paginateArgs =
    SelectionSet.succeed Community
        |> with Community.name
        |> with Community.description
        |> with (Eos.symbolSelectionSet Community.symbol)
        |> with Community.logo
        |> with (Eos.nameSelectionSet Community.creator)
        |> with Community.memberCount
        |> with (Community.members accountSelectionSet)
        |> with
            (Community.transfers
                paginateArgs
                transferConnectionSelectionSet
            )
        |> with (Community.objectives objectiveSelectionSet)



-- Communities Query


communitiesQuery : SelectionSet (List Metadata) RootQuery
communitiesQuery =
    communitiesSelectionSet
        (\args ->
            { args | first = Present 0 }
        )
        |> Query.communities


logoTitleQuery : Symbol -> SelectionSet (Maybe DashboardInfo) RootQuery
logoTitleQuery symbol =
    Query.community { symbol = symbolToString symbol } <| dashboardSelectionSet


type alias WithObjectives =
    { metadata : Metadata
    , objectives : List Objective
    }


communityQuery : Symbol -> SelectionSet (Maybe Community) RootQuery
communityQuery symbol =
    Query.community { symbol = symbolToString symbol } <|
        communitySelectionSet
            (\args ->
                { args | first = Present 10 }
            )


logoUrl : String -> Maybe String -> String
logoUrl ipfsUrl maybeHash =
    case maybeHash of
        Nothing ->
            logoPlaceholder ipfsUrl

        Just hash ->
            if String.isEmpty (String.trim hash) then
                logoPlaceholder ipfsUrl

            else
                ipfsUrl ++ "/" ++ hash


logoBackground : String -> Maybe String -> Html.Attribute msg
logoBackground ipfsUrl maybeHash =
    Html.Attributes.style "background-image"
        ("url(" ++ logoUrl ipfsUrl maybeHash ++ ")")


logoPlaceholder : String -> String
logoPlaceholder ipfsUrl =
    ipfsUrl ++ "/QmXuf6y8TMGRN96HZEy86c8N9aDseaeyuCQ5qVLqPyd8Ld"



-- OBJECTIVE


type alias Objective =
    { id : ObjectiveId
    , description : String
    , creator : Eos.Name
    , actions : List Action
    }


type ObjectiveId
    = ObjectiveId Int


objectiveSelectionSet : SelectionSet Objective Bespiral.Object.Objective
objectiveSelectionSet =
    SelectionSet.succeed Objective
        |> with
            (Objective.id
                |> SelectionSet.map ObjectiveId
            )
        |> with Objective.description
        |> with (Eos.nameSelectionSet Objective.creatorId)
        |> with (Objective.actions identity actionSelectionSet)


decodeObjectiveId : Decoder ObjectiveId
decodeObjectiveId =
    Decode.map ObjectiveId Decode.int


encodeObjectiveId : ObjectiveId -> Value
encodeObjectiveId (ObjectiveId i) =
    Encode.int i


unwrapObjectiveId : ObjectiveId -> Int
unwrapObjectiveId (ObjectiveId i) =
    i


type alias CreateObjectiveAction =
    { symbol : Symbol
    , description : String
    , creator : Eos.Name
    }


encodeCreateObjectiveAction : CreateObjectiveAction -> Value
encodeCreateObjectiveAction c =
    Encode.object
        [ ( "cmm_asset", Encode.string ("0 " ++ Eos.symbolToString c.symbol) )
        , ( "description", Encode.string c.description )
        , ( "creator", Eos.encodeName c.creator )
        ]



-- ACTION


type alias Action =
    { description : String
    , reward : Float
    , verificationReward : Float
    , creator : Eos.Name
    , validators : List Validator
    , usages : Int
    , usagesLeft : Int
    , deadline : DateTime
    , verificationType : VerificationType
    }


type alias Validator =
    { validator : Profile }


actionSelectionSet : SelectionSet Action Bespiral.Object.Action
actionSelectionSet =
    SelectionSet.succeed Action
        |> with Action.description
        |> with Action.reward
        |> with Action.verifierReward
        |> with (Eos.nameSelectionSet Action.creatorId)
        |> with
            (Action.validators validatorSelectionSet
                |> SelectionSet.map (Maybe.withDefault [])
            )
        |> with Action.usages
        |> with Action.usagesLeft
        |> with Action.deadline
        |> with Action.verificationType


validatorSelectionSet : SelectionSet Validator Bespiral.Object.Validator
validatorSelectionSet =
    SelectionSet.succeed Validator
        |> with (Bespiral.Object.Validator.validator accountSelectionSet)


type Verification
    = Manually Verifiers
    | Automatically String


type alias Verifiers =
    { verifiers : List String
    , reward : Float
    }



---- ACTION CREATE


type alias CreateActionAction =
    { objective_id : ObjectiveId
    , description : String
    , reward : String
    , verifier_reward : String
    , creator : Eos.Name
    }


encodeCreateActionAction : CreateActionAction -> Value
encodeCreateActionAction c =
    Encode.object
        [ ( "objective_id", encodeObjectiveId c.objective_id )
        , ( "description", Encode.string c.description )
        , ( "reward", Encode.string c.reward )
        , ( "verifier_reward", Encode.string c.verifier_reward )
        , ( "creator", Eos.encodeName c.creator )
        ]



-- Balance


type alias Balance =
    { asset : Eos.Asset
    , lastActivity : Posix
    }


decodeBalance : Decoder Balance
decodeBalance =
    Decode.succeed Balance
        |> required "balance" Eos.decodeAsset
        |> required "last_activity" Utils.decodeTimestamp



-- Transaction


type alias Transaction =
    { id : String
    , accountFrom : Eos.Name
    , symbol : Eos.Symbol
    }


decodeTransaction : Decoder Transaction
decodeTransaction =
    Decode.succeed Transaction
        |> required "txId" string
        |> required "accountFrom" Eos.nameDecoder
        |> required "symbol" Eos.symbolDecoder



-- CREATE COMMUNITY


type alias CreateCommunityData =
    { cmmAsset : Eos.Asset
    , creator : Eos.Name
    , logoHash : String
    , name : String
    , description : String
    , inviterReward : Eos.Asset
    , invitedReward : Eos.Asset
    }


createCommunityData :
    { accountName : Eos.Name
    , symbol : Eos.Symbol
    , logoHash : String
    , name : String
    , description : String
    }
    -> CreateCommunityData
createCommunityData params =
    { cmmAsset =
        { amount = 0
        , symbol = params.symbol
        }
    , creator = params.accountName
    , logoHash = params.logoHash
    , name = params.name
    , description = params.description
    , inviterReward =
        { amount = 0
        , symbol = params.symbol
        }
    , invitedReward =
        { amount = 0
        , symbol = params.symbol
        }
    }


encodeCreateCommunityData : CreateCommunityData -> Value
encodeCreateCommunityData c =
    Encode.object
        [ ( "cmm_asset", Eos.encodeAsset c.cmmAsset )
        , ( "creator", Eos.encodeName c.creator )
        , ( "logo", Encode.string c.logoHash )
        , ( "name", Encode.string c.name )
        , ( "description", Encode.string c.description )
        , ( "inviter_reward", Eos.encodeAsset c.inviterReward )
        , ( "invited_reward", Eos.encodeAsset c.invitedReward )
        ]


type alias UpdateLogoData =
    { asset : Eos.Asset
    , logoHash : String
    }


encodeUpdateLogoData : UpdateLogoData -> Value
encodeUpdateLogoData c =
    Encode.object
        [ ( "logo", Encode.string c.logoHash )
        , ( "cmm_asset", Eos.encodeAsset c.asset )
        ]