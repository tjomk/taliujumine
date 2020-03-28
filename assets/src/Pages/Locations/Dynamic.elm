module Pages.Locations.Dynamic exposing (Model, Msg, page)

import Generated.Locations.Params as Params
import Html exposing (Html, a, article, b, br, button, div, figure, form, h2, h4, i, img, input, label, li, p, section, span, text, ul)
import Html.Attributes exposing (class, href, name, placeholder, src, target, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Iso8601
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import RemoteData exposing (WebData)
import Spa.Page
import Task
import Time
import Time.Distance exposing (inWords)
import Utils.Spa exposing (Page)


page : Page Params.Dynamic Model Msg model msg appMsg
page =
    Spa.Page.element
        { title = title
        , init = always init
        , update = always update
        , subscriptions = always subscriptions
        , view = always view
        }



-- INIT


type alias Checkin =
    { id : Int
    , timestamp : String
    , user : User
    }


type alias Location =
    { id : Int
    , name : String
    , city : String
    , country : String
    , slug : String
    , description : String
    , url : String
    , location : ( Float, Float )
    , checkins : List Checkin
    }


type alias User =
    { id : Int
    , fullName : String
    , username : String
    }


type alias Model =
    { location : WebData Location
    , locationName : String
    , users : WebData (List User)
    , searchTerm : String
    , time : Time.Posix
    , showCheckinModal : Bool
    , checkinUser : Maybe User
    }


init : Params.Dynamic -> ( Model, Cmd Msg )
init { param1 } =
    ( Model RemoteData.Loading param1 RemoteData.NotAsked "" (Time.millisToPosix 0) False Maybe.Nothing
    , Cmd.batch
        [ fetchLocationInfo (getLocationName param1)
        , Task.perform GetCurrentTime Time.now
        ]
    )


getLocationName : String -> String
getLocationName location =
    if String.startsWith "@" location then
        String.dropLeft 1 location

    else
        ""



-- UPDATE


type Msg
    = LocationInfoReceived (WebData Location)
    | UsersListReceived (WebData (List User))
    | SearchTermUpdated String
    | GetCurrentTime Time.Posix
    | ShowConfirmationModal (Maybe User)
    | CloseConfirmationModal
    | HideSearchResults


title : { global : globalModel, model : Model } -> String
title data =
    case data.model.location of
        RemoteData.NotAsked ->
            "Loading..."

        RemoteData.Loading ->
            "Loading..."

        RemoteData.Success location ->
            location.name ++ " - " ++ location.description

        RemoteData.Failure error ->
            "Error"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetCurrentTime time ->
            ( { model | time = time }, Cmd.none )

        LocationInfoReceived response ->
            ( { model | location = response }, Cmd.none )

        SearchTermUpdated searchTerm ->
            if String.length searchTerm < 4 then
                ( { model | searchTerm = searchTerm }, Cmd.none )

            else
                ( { model | searchTerm = searchTerm }, searchUsers searchTerm )

        UsersListReceived response ->
            ( { model | users = response }, Cmd.none )

        ShowConfirmationModal user ->
            ( { model | showCheckinModal = True, checkinUser = user }, Cmd.none )

        CloseConfirmationModal ->
            ( { model | showCheckinModal = False, searchTerm = "" }, Cmd.none )

        HideSearchResults ->
            ( { model | searchTerm = "" }, Cmd.none )



-- API


searchUsers : String -> Cmd Msg
searchUsers searchTerm =
    let
        endpoint =
            "http://localhost:4000/api/v1/users?q=" ++ searchTerm
    in
    Http.get
        { url = endpoint
        , expect =
            Http.expectJson (RemoteData.fromResult >> UsersListReceived) usersListDecoder
        }


fetchLocationInfo : String -> Cmd Msg
fetchLocationInfo locationName =
    Http.get
        { url = "http://localhost:4000/api/v1/locations/" ++ locationName
        , expect =
            Http.expectJson (RemoteData.fromResult >> LocationInfoReceived) locationDecoder
        }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


getModalClasses : Bool -> String
getModalClasses isActive =
    if isActive then
        "modal is-active"

    else
        "modal"


viewCheckinForm : Maybe User -> Html Msg
viewCheckinForm user =
    form []
        [ case user of
            Just v ->
                text ("Well done, " ++ v.fullName ++ "!")

            Nothing ->
                div [ class "field" ]
                    [ label [ class "label" ] [ text "Your name" ]
                    , div [ class "control" ]
                        [ input [ class "input", type_ "text", name "name", placeholder "Optional" ] []
                        ]
                    ]
        , div [ class "field" ]
            [ label [ class "label" ] [ text "How was it (in a few words)?" ]
            , div [ class "control" ]
                [ input [ class "input", type_ "text", name "comment", placeholder "Optional" ] []
                ]
            ]
        , div [ class "field" ]
            [ label [ class "label" ] [ text "Minutes spent in water" ]
            , div [ class "control" ]
                [ input [ class "input", type_ "text", name "minutes", placeholder "Optional" ] []
                ]
            ]
        , div [ class "field" ]
            [ label [ class "label" ] [ text "Times you swam" ]
            , div [ class "control" ]
                [ input [ class "input", type_ "text", name "times", placeholder "Optional" ] []
                ]
            ]
        , div [ class "buttons" ]
            [ button [ class "button is-primary" ] [ text "Checkin" ]
            , button [ class "button is-info", onClick CloseConfirmationModal ] [ text "Cancel" ]
            ]
        ]


renderView : Model -> Html Msg
renderView model =
    case model.location of
        RemoteData.NotAsked ->
            text "Haven't queried"

        RemoteData.Loading ->
            text "Fetching..."

        RemoteData.Success location ->
            div []
                [ h2 [ class "is-size-2" ] [ text location.name ]
                , div [ class "columns is-flex-touch is-reverse-columns-touch" ]
                    [ div [ class "column is-two-thirds" ]
                        [ viewUserSearch model
                        , viewStats model
                        , viewCheckins location.checkins model.time
                        ]
                    , div [ class "column" ]
                        [ viewSidebar location
                        ]
                    ]
                , div [ class (getModalClasses model.showCheckinModal) ]
                    [ div [ class "modal-background", onClick CloseConfirmationModal ] []
                    , div [ class "modal-content" ]
                        [ article [ class "message" ]
                            [ div [ class "message-header" ]
                                [ p [] [ text "How was your swim today?" ]
                                ]
                            , div [ class "message-body" ] [ viewCheckinForm model.checkinUser ]
                            ]
                        ]
                    , button [ class "modal-close is-large", onClick CloseConfirmationModal ] []
                    ]
                ]

        RemoteData.Failure error ->
            text ("Oops! " ++ parseError error)


viewCheckin : Time.Posix -> Checkin -> Html a
viewCheckin currentTime checkin =
    let
        ts =
            Iso8601.toTime checkin.timestamp
                |> Result.withDefault (Time.millisToPosix 0)

        t =
            inWords ts currentTime
    in
    li []
        [ span [ class "icon is-small" ]
            [ i [ class "fa fa-map-marker" ] []
            ]
        , text (checkin.user.username ++ " checked in " ++ t)
        ]


viewCheckins : List Checkin -> Time.Posix -> Html a
viewCheckins checkins currentTime =
    let
        viewCheckinWithTime =
            viewCheckin currentTime
    in
    ul [ class "block-list is-small is-outlined" ] (List.map viewCheckinWithTime checkins)


parseError : Http.Error -> String
parseError httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "Server is taking too long to respond. Please try again later."

        Http.NetworkError ->
            "Unable to reach server."

        Http.BadStatus statusCode ->
            "Request failed with status code: " ++ String.fromInt statusCode

        Http.BadBody message ->
            message


viewUserRow : User -> Html Msg
viewUserRow user =
    div [ class "dropdown-item", onClick (ShowConfirmationModal (Just user)) ] [ text (user.fullName ++ " (" ++ user.username ++ ")") ]


viewNewUserEntry : Html Msg
viewNewUserEntry =
    div [ class "dropdown-item", onClick (ShowConfirmationModal Nothing) ]
        [ span [ class "icon is-small" ]
            [ i [ class "fa fa-map-marker" ] []
            ]
        , text "Checkin without account"
        ]


viewSearchResults : Model -> Html Msg
viewSearchResults model =
    case model.users of
        RemoteData.NotAsked ->
            div [] []

        RemoteData.Loading ->
            -- showLoader
            text "Loading"

        RemoteData.Failure error ->
            text ("Oops! " ++ parseError error)

        RemoteData.Success users ->
            if String.length model.searchTerm < 4 then
                div [] []

            else if List.length users > 0 then
                div [ class "dropdown-content" ]
                    (List.append (List.map viewUserRow users) (List.singleton viewNewUserEntry))

            else
                div [ class "dropdown-content" ] [ viewNewUserEntry ]


viewUserSearch : Model -> Html Msg
viewUserSearch model =
    form [ class "mb-2 mt-1" ]
        [ p [ class "mb-1" ] [ text "Just start typing your name or nickname to checkin here." ]
        , div [ class "dropdown is-active" ]
            [ div [ class "dropdown-trigger" ]
                [ div [ class "field" ]
                    [ p [ class "control is-expanded has-icons-right" ]
                        [ input [ class "input", type_ "search", placeholder "Search...", value model.searchTerm, onInput SearchTermUpdated ] []
                        , span [ class "icon is-small is-right" ]
                            [ i [ class "fa fa-search" ] [] ]
                        ]
                    ]
                ]
            , div [ class "dropdown-menu" ]
                [ viewSearchResults model
                ]
            ]
        ]


pluralPeople : Int -> String
pluralPeople total =
    if total == 1 then
        "person"

    else
        "people"


viewStats : Model -> Html a
viewStats model =
    h4 [ class "is-size-4" ]
        [ text "A total of "
        , b [] [ text (String.fromInt 95) ]
        , text " "
        , text (pluralPeople 95)
        , text " checked in here today. Latest checkins:"
        ]


viewSidebar : Location -> Html a
viewSidebar locationInfo =
    let
        mapUrl =
            "https://www.openstreetmap.org/#map=17/"
                ++ String.fromFloat (Tuple.first locationInfo.location)
                ++ "/"
                ++ String.fromFloat (Tuple.second locationInfo.location)

        imageUrl =
            "https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/"
                ++ String.fromFloat (Tuple.second locationInfo.location)
                ++ ","
                ++ String.fromFloat (Tuple.first locationInfo.location)
                ++ ",16,0.00,0.00/600x450@2x?access_token=pk.eyJ1IjoidGpvbWsiLCJhIjoiY2ltdzZwZ3piMDBhN3Y5bTF5MXp1N3ZpdSJ9.KQStq6NWM4fgI44FoEgJ0Q"
    in
    div [ class "card" ]
        [ div [ class "card-image" ]
            [ figure [ class "image is-4by3" ]
                [ a [ href mapUrl, target "_blank" ]
                    [ img [ src imageUrl ] []
                    ]
                ]
            ]
        , div [ class "card-content" ]
            [ div [ class "content" ]
                [ p []
                    [ span [ class "icon" ] [ i [ class "fa fa-compass" ] [] ]
                    , text locationInfo.description
                    ]
                , p []
                    [ span [ class "icon" ] [ i [ class "fa fa-clock-o" ] [] ]
                    , text "this is opening time"
                    ]
                , p []
                    [ span [ class "icon" ] [ i [ class "fa fa-globe" ] [] ]
                    , a [ href locationInfo.url, target "_blank" ] [ text locationInfo.url ]
                    ]
                ]
            ]
        ]



-- MAIN VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ renderView model ]



-- JSON


locationDecoder : Decoder Location
locationDecoder =
    Decode.field "data"
        (Decode.succeed Location
            |> required "id" Decode.int
            |> required "name" Decode.string
            |> required "city" Decode.string
            |> required "country" Decode.string
            |> required "slug" Decode.string
            |> required "description" Decode.string
            |> required "url" Decode.string
            |> required "location" decodeTuple
            |> required "checkins" (Decode.list checkinDecoder)
        )


checkinDecoder : Decoder Checkin
checkinDecoder =
    Decode.succeed Checkin
        |> required "id" Decode.int
        |> required "created" Decode.string
        |> required "user" userDecoder


checkinListDecoder : Decoder (List Checkin)
checkinListDecoder =
    Decode.at [ "checkins" ] (Decode.list checkinDecoder)


userDecoder : Decoder User
userDecoder =
    Decode.succeed User
        |> required "id" Decode.int
        |> required "fullName" Decode.string
        |> required "username" Decode.string


usersListDecoder : Decoder (List User)
usersListDecoder =
    Decode.at [ "data" ] (Decode.list userDecoder)


decodeTuple =
    Decode.map2 Tuple.pair
        (Decode.index 0 Decode.float)
        (Decode.index 1 Decode.float)
