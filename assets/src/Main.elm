module Main exposing (main)

import Http
import String
import Debug
import Browser exposing (application)
import Browser.Navigation as Nav
import Http exposing (Error(..), request)
import Html exposing (Html, section, div, form, input, a, i, p, text, span)
import Html.Attributes exposing (id, type_, class, placeholder, value)
import Html.Events exposing (onInput)
import Url exposing (Url, fromString)
import Json.Decode as Decode exposing (Decoder, string, list, int)
import Json.Decode.Pipeline exposing (required)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


-- MODELS


type AppState
    = SearchingUsers (ApiResponse (List User))
    | Home


type alias RootUrl =
    String


type alias User =
    { id: Int
    , fullName: String
    , username: String
    }


type alias Users =
    { data: List User }


type RemoteData e r
    = NotAsked
    | Loading
    | Failure e
    | Success r


type alias ApiResponse a =
    RemoteData Http.Error a


type alias Flags =
    { apiRootUrl : String
    }


type alias Model =
    { key : Nav.Key
    , url : Url
    , apiRootUrl : Maybe Url
    , searchTerm : String
    , state : AppState
    }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( Model key url (Url.fromString flags.apiRootUrl) "" Home, Cmd.none )


-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | SearchTermUpdated String
    | UsersRetrieved (Result Http.Error (List User))
    | UserClicked String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )

        SearchTermUpdated searchTerm ->
            if String.length searchTerm < 4 then
                ( { model | searchTerm = searchTerm, state = Home }, Cmd.none )
            else
                case model.apiRootUrl of
                    Nothing ->
                        ( model, Cmd.none )

                    Just rootUrl ->
                        ( { model | searchTerm = searchTerm }, searchUsers searchTerm )

        UsersRetrieved result ->
            case result of
                Ok users ->
                    ( { model | state = SearchingUsers (Success users) }, Cmd.none )

                Err error ->
                    ( { model | state = SearchingUsers (Failure error) }, Cmd.none )

        UserClicked userId ->
            case model.apiRootUrl of
                Nothing ->
                    ( model, Cmd.none )

                Just rootUrl ->
                    ( model, Nav.load ("/users/" ++ userId) )


-- VIEW


renderSearchRow: User -> Html msg
renderSearchRow item =
    a [ class "dropdown-item" ] [ text item.fullName ]


renderSearchResults : RootUrl -> ApiResponse (List User) -> Html Msg
renderSearchResults rootUrl response =
    case response of
        NotAsked ->
            div [][]

        Loading ->
            -- showLoader
            text "Loading"

        Failure error ->
            -- show error
            -- text "Oops! An error ocurred"
            text (Debug.toString error)

        Success users ->
            div [ class "dropdown-content" ] (List.map renderSearchRow users)


view : Model -> Browser.Document Msg
view model =
    { title = "Taliujumine"
    , body =
        [
            section [ class "section" ]
                [ div [ class "container" ]
                    [ form []
                        [ div [ class "dropdown is-active" ]
                            [ div [ class "dropdown-trigger" ]
                                [ div [ class "field" ]
                                    [ p [ class "control is-expanded has-icons-right" ]
                                        [ input [ class "input", type_ "search", placeholder "Search...", value model.searchTerm, onInput SearchTermUpdated ] []
                                        ,  span [ class "icon is-small is-right" ]
                                            [ i [ class "fas fa-search" ] [] ]
                                        ]
                                    ]
                                ]
                            , div [ class "dropdown-menu" ]
                                [ case model.state of
                                    Home ->
                                        div [][]
        
                                    SearchingUsers users ->
                                        case model.apiRootUrl of
                                            Nothing ->
                                                text ""
        
                                            Just rootUrl ->
                                                renderSearchResults (Url.toString rootUrl) users
                                ]
                            ]
                        ]
                    ]
                ]
        ]
    }


-- SUBSCRIPTION


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


-- API


searchUsers : String -> Cmd Msg
searchUsers searchTerm =
    let
        endpoint =
            "http://localhost:4000/api/v1/users?q=" ++ searchTerm
    in
    request
        { method = "GET"
        , headers = []
        , url = endpoint
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        , expect = Http.expectJson UsersRetrieved usersListDecoder
        }


-- JSON DECODERS


userDecoder : Decoder User
userDecoder =
    Decode.succeed User
        |> required "id" int 
        |> required "fullName" string
        |> required "username" string


usersListDecoder : Decoder (List User)
usersListDecoder =
    Decode.at [ "data" ] (Decode.list userDecoder)
