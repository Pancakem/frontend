module Page.Community.ActionEditor exposing (Model, Msg, initNew, msgToString, update, view)

import Account exposing (Profile)
import Api.Graphql
import Avatar exposing (Avatar)
import Bespiral.Enum.VerificationType as VerificationType exposing (VerificationType)
import Community exposing (Community)
import Eos exposing (Symbol)
import Eos.Account as Eos
import Graphql.Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, targetValue)
import I18Next exposing (t)
import Json.Decode as Json
import Page
import Select
import Session.LoggedIn as LoggedIn exposing (External(..))
import Session.Shared exposing (Shared)
import Simple.Fuzzy
import Time exposing (Posix)
import UpdateResult as UR



-- INIT


initNew : LoggedIn.Model -> Symbol -> String -> ( Model, Cmd Msg )
initNew loggedIn symbol objId =
    let
        shared =
            loggedIn.shared

        initialForm =
            Eos.symbolToString symbol
                |> newForm

        ( initStatus, obj ) =
            case String.toInt objId of
                Just id ->
                    ( LoadingCommunity, id )

                Nothing ->
                    ( InvalidObjective objId, 0 )
    in
    ( { status = initStatus
      , objective = obj
      , hasValidity = False
      , hasDeadline = False
      , hasMaxUsage = False
      , hasVerification = False
      , form = initialForm
      , community = Nothing
      , multiSelectState = Select.newState ""
      , selectedVerifiers = []
      }
    , Api.Graphql.query shared (Community.communityQuery symbol) CompletedCommunityLoad
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- MODEL


type alias Model =
    { status : Status
    , community : Maybe Community
    , objective : Int
    , hasValidity : Bool
    , hasDeadline : Bool
    , hasMaxUsage : Bool
    , hasVerification : Bool
    , form : Form

    -- verifiers
    , multiSelectState : Select.State
    , selectedVerifiers : List Profile
    }


type
    Status
    -- New Action
    = InvalidObjective String
    | LoadingCommunity
    | LoadingFailed (Graphql.Http.Error (Maybe Community))
    | EditingNew (List Problem)



-- UPDATE


type alias UpdateResult =
    UR.UpdateResult Model Msg (External Msg)


type Msg
    = Ignored
    | CompletedCommunityLoad (Result (Graphql.Http.Error (Maybe Community)) (Maybe Community))
    | SetValidity String
    | SetVerification String
    | OnSelectVerifier (Maybe Profile)
    | OnRemoveVerifier Profile
    | SelectMsg (Select.Msg Profile)


update : Msg -> Model -> LoggedIn.Model -> UpdateResult
update msg model loggedIn =
    case msg of
        Ignored ->
            model
                |> UR.init

        CompletedCommunityLoad (Err err) ->
            { model | status = LoadingFailed err }
                |> UR.init
                |> UR.logGraphqlError msg err

        CompletedCommunityLoad (Ok comm) ->
            case comm of
                Just c ->
                    { model
                        | status = EditingNew []
                        , community = Just c
                    }
                        |> UR.init

                Nothing ->
                    model
                        |> UR.init
                        |> UR.logImpossible msg []

        SetValidity validity ->
            let
                val =
                    if validity == "yes" then
                        True

                    else
                        False
            in
            { model | hasValidity = val }
                |> UR.init

        SetVerification verification ->
            let
                ver =
                    if verification == "yes" then
                        True

                    else
                        False
            in
            { model | hasVerification = ver }
                |> UR.init

        OnSelectVerifier maybeProfile ->
            let
                selectedProfiles =
                    maybeProfile
                        |> Maybe.map (List.singleton >> List.append model.selectedVerifiers)
                        |> Maybe.withDefault []
            in
            { model | selectedVerifiers = selectedProfiles }
                |> UR.init

        OnRemoveVerifier profile ->
            let
                selectedProfiles =
                    List.filter (\currVerifier -> currVerifier.accountName /= profile.accountName)
                        model.selectedVerifiers
            in
            { model | selectedVerifiers = selectedProfiles }
                |> UR.init

        SelectMsg subMsg ->
            let
                ( updated, cmd ) =
                    Select.update (selectConfig loggedIn.shared False) subMsg model.multiSelectState
            in
            { model | multiSelectState = updated }
                |> UR.init
                |> UR.addCmd cmd



-- VIEW


view : LoggedIn.Model -> Model -> Html Msg
view loggedIn model =
    let
        defaultContainer =
            div [ class "mx-5 sm:mx-10" ]

        shared =
            loggedIn.shared

        t s =
            I18Next.t shared.translations s
    in
    case model.status of
        InvalidObjective badId ->
            defaultContainer
                [ Page.viewTitle (t "error.objective.invalid_id")
                , p [] [ text badId ]
                ]

        LoadingFailed err ->
            Page.fullPageGraphQLError (t "error.invalidSymbol") err

        LoadingCommunity ->
            defaultContainer
                [ Page.fullPageLoading ]

        EditingNew problems ->
            case model.community of
                Nothing ->
                    defaultContainer
                        [ Page.fullPageLoading ]

                Just comm ->
                    defaultContainer
                        ([ Page.viewTitle (t "community.actions.new") ]
                            ++ viewForm loggedIn.shared comm model
                        )


viewForm : Shared -> Community -> Model -> List (Html Msg)
viewForm shared community model =
    let
        ipfsUrl =
            shared.endpoints.ipfs

        logoLink =
            Community.logoUrl ipfsUrl (Just community.logo)
    in
    [ div [ class "bg-white rounded-lg" ]
        [ div [ class "px-4 py-6 border-b border-gray-500" ]
            [ img [ src logoLink, class "w-16 h-16 mr-4 inline" ] []
            , span [ class "font-sans text-heading font-medium" ] [ text community.title ]
            ]
        , div [ class "py-6 px-4" ]
            [ span [ class "font-sans text-caption text-green leading-caption uppercase" ]
                [ text "Activity Description" ]
            , textarea [ class "form-textarea block w-full rounded border border-gray-500 mb-10 text-gray-900", rows 5 ] []
            , span [ class "font-sans text-caption text-green leading-caption uppercase" ]
                [ text "Reward" ]
            , div [ class "flex flex-row sm:w-1/4 mb-10" ]
                [ input [ class "form-input block w-4/5 border-t border-b border-l border-gray-500 text-grey-900 rounded-l" ] []
                , span
                    [ class "border-r border-b border-t border-gray-500 text-white font-sans items-center justify-center bg-indigo-500 text-body w-1/5 flex rounded-r" ]
                    [ text (Eos.symbolToString community.symbol) ]
                ]
            , div [ class "sm:w-select" ]
                [ div [ class "flex flex-row justify-between" ]
                    [ p [ class "font-sans text-caption text-green leading-caption uppercase" ]
                        [ text "Does it have validity?" ]
                    , div [ class "text-orange-300 relative mb-1 text-caption leading-caption uppercase tooltip-container" ]
                        [ text "What is it?"
                        , span [ class "bg-black text-white absolute z-10 py-3 px-4 top-1 w-select right-0 rounded" ]
                            [ text " I Is the tooltip text" ]
                        ]
                    ]
                , select
                    [ class "form-select block w-full border border-gray-500 rounded mb-10 text-gray-900"
                    , on "change" (Json.map SetValidity targetValue)
                    ]
                    [ option [ value "no" ] [ span [ class "capitalize" ] [ text "No" ] ]
                    , option [ value "yes" ] [ span [ class "capitalize" ] [ text "Yes" ] ]
                    ]
                ]
            , if model.hasValidity then
                div [ class "mb-10 sm:w-select" ]
                    [ div [ class "mb-6 flex flex-row text-body items-bottom" ]
                        [ input [ id "date", type_ "checkbox", class "form-checkbox mr-2 p-1 border-gray-500 " ] []
                        , label [ for "date", class "capitalize font-sans" ] [ text "validity by date" ]
                        ]
                    , span [ class "w-full font-sans text-caption text-green leading-caption uppercase" ]
                        [ text "Choose Date" ]
                    , input
                        [ type_ "text"
                        , class "mb-10 w-full font-sans border border-gray-500 rounded form-input bg-gray-500 text-black placeholder-black"
                        , placeholder "dd/mm/yyyy"
                        ]
                        []
                    , div [ class "mb-6 flex flex-row text-body items-bottom" ]
                        [ input [ id "quantity", type_ "checkbox", class "form-checkbox mr-2" ] []
                        , label [ for "quantity", class "capitalize font-sans" ] [ text "validity by quantity" ]
                        ]
                    , span [ class "font-sans text-caption text-green leading-caption uppercase" ]
                        [ text "choose quantity" ]
                    , input
                        [ type_ "number"
                        , class "w-full font-sans border border-gray-500 rounded form-input"
                        ]
                        []
                    ]

              else
                text ""
            , div [ class "sm:w-select mb-10" ]
                [ div [ class "flex flex-row justify-between font-sans leading-caption uppercase text-caption" ]
                    [ p [ class "text-green" ]
                        [ text "Does it need verification?" ]
                    , div [ class "text-orange-300 relative mb-1 tooltip-container" ]
                        [ text "What is it?"
                        , span [ class "bg-black text-white absolute z-10 py-3 px-4 top-1 w-select right-0 rounded" ]
                            [ text " I Is the tooltip text" ]
                        ]
                    ]
                , select
                    [ on "change" (Json.map SetVerification targetValue)
                    , class "form-select block w-full border border-gray-500 rounded mb-10 text-gray-900"
                    ]
                    [ option [ value "no" ] [ text "No, it is automatically" ]
                    , option [ value "yes" ] [ text " Yes" ]
                    ]
                , if model.hasVerification then
                    div []
                        [ span [ class "font-sans text-caption text-green leading-caption uppercase" ]
                            [ text "choose the verifiers" ]
                        , div [ class "mb-10" ]
                            [ viewVerifierSelect shared model False
                            , viewSelectedVerifiers shared model
                            ]
                        , span [ class "font-sans text-caption text-green leading-caption uppercase" ]
                            [ text "Reward for verifiers" ]
                        , div [ class "flex flex-row mb-10" ]
                            [ input
                                [ class "form-input block w-4/5 border-t border-b border-l border-gray-500 text-grey-900 rounded-l" ]
                                []
                            , span
                                [ class "border-r border-b border-t border-gray-500 text-white font-sans items-center justify-center bg-indigo-500 text-body w-1/5 flex rounded-r" ]
                                [ text (Eos.symbolToString community.symbol) ]
                            ]
                        , div [ class "flex flex-row justify-between font-sans text-caption leading-caption uppercase" ]
                            [ p [ class "text-green" ]
                                [ text "Minimum number of votes" ]
                            , div [ class "text-orange-300 relative mb-1 tooltip-container" ]
                                [ text "What is it?"
                                , span [ class "bg-black text-white absolute z-10 py-3 px-4 top-1 w-select right-0 rounded" ]
                                    [ text " I Is the tooltip text" ]
                                ]
                            ]
                        , input [ class "w-full form-input border border-gray-500 rounded text-gray-900 placeholder-gray-900" ]
                            []
                        ]

                  else
                    text ""
                ]
            , div [ class "flex align-center justify-center" ]
                [ button
                    [ class "uppercase font-sans text-white text-body bg-orange-300 rounded-super w-40 h-10" ]
                    [ text "Create" ]
                ]
            ]
        ]
    ]


viewSelectedVerifiers : Shared -> Model -> Html Msg
viewSelectedVerifiers shared model =
    let
        ipfsUrl =
            shared.endpoints.ipfs

        verifiers =
            model.selectedVerifiers
                |> List.map
                    (\p ->
                        div
                            [ onClick (OnRemoveVerifier p)
                            , class "flex flex-col m-2 items-center"
                            ]
                            [ Avatar.view ipfsUrl p.avatar "h-7 w-7"
                            , span [ class "mt-1 text-red font-sans text-caption uppercase leading-caption" ]
                                [ text "Remove" ]
                            ]
                    )
    in
    div [ class "flex flex-row mt-heading flex-wrap" ] verifiers



-- Configure Select


filter : Int -> (a -> String) -> String -> List a -> Maybe (List a)
filter minChars toLabel query items =
    if String.length query < minChars then
        Nothing

    else
        items
            |> Simple.Fuzzy.filter toLabel query
            |> Just


selectConfig : Shared -> Bool -> Select.Config Msg Profile
selectConfig shared isDisabled =
    Select.newConfig
        { onSelect = OnSelectVerifier
        , toLabel = \p -> Eos.nameToString p.accountName
        , filter = filter 2 (\p -> Eos.nameToString p.accountName)
        }
        |> Select.withMultiSelection True
        |> Select.withInputClass "form-input w-full text-gray-900 placeholder-gray-900"
        |> Select.withClear False
        |> Select.withMultiInputItemContainerClass "hidden h-0"
        |> Select.withNotFound "No matches"
        |> Select.withNotFoundClass "text-red"
        |> Select.withNotFoundStyles [ ( "padding", "0 2rem" ) ]
        |> Select.withDisabled isDisabled
        |> Select.withHighlightedItemClass "autocomplete-item-highlight"
        |> Select.withPrompt (t shared.translations "account.my_wallet.transfer.send_to_placeholder")
        |> Select.withItemHtml (viewAutoCompleteItem shared)


viewAutoCompleteItem : Shared -> Profile -> Html Never
viewAutoCompleteItem shared profile =
    let
        ipfsUrl =
            shared.endpoints.ipfs
    in
    div [ class "autocomplete-item" ]
        [ Avatar.view ipfsUrl profile.avatar "profile-img-avatar-select"
        , text (Eos.nameToString profile.accountName)
        , text " "
        , case profile.userName of
            Just name ->
                text ("(" ++ name ++ ")")

            Nothing ->
                text ""
        ]


viewVerifierSelect : Shared -> Model -> Bool -> Html Msg
viewVerifierSelect shared model isDisabled =
    let
        users =
            Maybe.map .members model.community
                |> Maybe.withDefault []
    in
    Html.map SelectMsg (Select.view (selectConfig shared isDisabled) model.multiSelectState users model.selectedVerifiers)



-- FORM


type Problem
    = InvalidEntry ValidatedField String
    | ServerError String


type ValidatedField
    = Description
    | Reward
    | Deadline
    | MaxUsage
    | Verifiers
    | MinVotes


type alias Form =
    { description : String
    , symbol : String
    , reward : Int
    , deadline : Maybe Posix
    , maxUsage : Maybe Int
    , verificationType : VerificationType
    , verifiers : Maybe (List Profile)
    , verifierReward : Int
    , minVotes : Int
    , objective : Int
    }


newForm : String -> Form
newForm sym =
    { description = ""
    , symbol = sym
    , reward = 0
    , deadline = Nothing
    , maxUsage = Nothing
    , verificationType = VerificationType.Automatic
    , verifiers = Nothing
    , verifierReward = 0
    , minVotes = 0
    , objective = 0
    }



-- UTILS


msgToString : Msg -> List String
msgToString msg =
    case msg of
        Ignored ->
            [ "Ignored" ]

        CompletedCommunityLoad _ ->
            [ "CompletedCommunityLoad" ]

        SetValidity val ->
            [ "SetValidity", val ]

        SetVerification ver ->
            [ "SetVerification", ver ]

        OnSelectVerifier _ ->
            [ "OnSelectVerifier" ]

        OnRemoveVerifier _ ->
            [ "OnRemoveVerifier" ]

        SelectMsg _ ->
            [ "SelectMsg" ]