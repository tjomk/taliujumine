module Pages.Locations.Dynamic exposing (Model, Msg, page)

import Generated.Locations.Params as Params
import Html exposing (Html, a, br, div, figure, form, i, img, input, p, section, span, text)
import Html.Attributes exposing (class, href, placeholder, src, target, type_, value)
import Html.Events exposing (onInput)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import RemoteData exposing (WebData)
import Spa.Page
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
    , fullName : String
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
    }


type alias User =
    { id : Int
    , fullName : String
    , username : String
    }


type alias Model =
    { location : WebData Location
    , locationName : String
    , checkins : List Checkin
    , users : WebData (List User)
    , searchTerm : String
    }


init : Params.Dynamic -> ( Model, Cmd Msg )
init { param1 } =
    ( Model RemoteData.Loading param1 [] RemoteData.NotAsked ""
    , fetchLocationInfo (getLocationName param1)
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


title : { global : globalModel, model : Model } -> String
title data =
    case data.model.location of
        RemoteData.NotAsked ->
            "Loading..."

        RemoteData.Loading ->
            "Loading..."

        RemoteData.Success location ->
            location.name

        RemoteData.Failure error ->
            "Error"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LocationInfoReceived response ->
            ( { model | location = response }, Cmd.none )

        SearchTermUpdated searchTerm ->
            if String.length searchTerm < 4 then
                ( { model | searchTerm = searchTerm }, Cmd.none )

            else
                ( { model | searchTerm = searchTerm }, searchUsers searchTerm )

        UsersListReceived response ->
            ( { model | users = response }, Cmd.none )



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


renderView : Model -> Html Msg
renderView model =
    case model.location of
        RemoteData.NotAsked ->
            text "haven't queried"

        RemoteData.Loading ->
            text "Fetching..."

        RemoteData.Success location ->
            div [ class "columns is-flex-touch is-reverse-columns-touch" ]
                [ div [ class "column is-two-thirds" ]
                    [ text location.name
                    , viewUserSearch model
                    ]
                , div [ class "column" ]
                    [ viewSidebar location
                    ]
                ]

        RemoteData.Failure error ->
            text ("Oops! " ++ parseError error)


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


viewUserRow : User -> Html a
viewUserRow item =
    a [ class "dropdown-item", href ("/users/@" ++ item.username) ] [ text item.fullName ]


viewSearchResults : Model -> Html a
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
            div [ class "dropdown-content" ] (List.map viewUserRow users)


viewUserSearch : Model -> Html Msg
viewUserSearch model =
    section [ class "section" ]
        [ div [ class "container" ]
            [ form []
                [ div [ class "dropdown is-active" ]
                    [ div [ class "dropdown-trigger" ]
                        [ div [ class "field" ]
                            [ p [ class "control is-expanded has-icons-right" ]
                                [ input [ class "input", type_ "search", placeholder "Search...", value model.searchTerm, onInput SearchTermUpdated ] []
                                , span [ class "icon is-small is-right" ]
                                    [ i [ class "fas fa-search" ] [] ]
                                ]
                            ]
                        ]
                    , div [ class "dropdown-menu" ]
                        [ viewSearchResults model
                        ]
                    ]
                ]
            ]
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
        )


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
