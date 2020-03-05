module Pages.Users.Dynamic exposing (Model, Msg, page)

import Generated.Users.Params as Params
import Html exposing (Html, br, div, text)
import Http
import Json.Decode as Decode exposing (Decoder, field, int, string)
import Json.Decode.Pipeline exposing (required)
import RemoteData exposing (WebData)
import Spa.Page
import Utils.Spa exposing (Page)


page : Page Params.Dynamic Model Msg model msg appMsg
page =
    Spa.Page.element
        { title = always "Users.Dynamic"
        , init = always init
        , update = always update
        , subscriptions = always subscriptions
        , view = always view
        }



-- INIT


type alias User =
    { id : Int
    , fullName : String
    , username : String
    }


type alias Model =
    { user : WebData User
    , requestedUsername : String
    }


init : Params.Dynamic -> ( Model, Cmd Msg )
init { param1 } =
    ( Model RemoteData.Loading (getUsername param1)
    , fetchUser (getUsername param1)
    )


getUsername : String -> String
getUsername username =
    if String.startsWith "@" username then
        String.dropLeft 1 username

    else
        ""



-- UPDATE


type Msg
    = DataReceived (WebData User)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DataReceived response ->
            ( { model | user = response }, Cmd.none )


fetchUser : String -> Cmd Msg
fetchUser username =
    Http.get
        { url = "http://localhost:4000/api/v1/users/" ++ username
        , expect =
            Http.expectJson (RemoteData.fromResult >> DataReceived) userDecoder
        }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


viewUser : Model -> Html Msg
viewUser model =
    case model.user of
        RemoteData.NotAsked ->
            text "haven't queried"

        RemoteData.Loading ->
            text "Fetching..."

        RemoteData.Success user ->
            text ("Fetched user: " ++ user.fullName)

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


view : Model -> Html Msg
view model =
    div []
        [ text ("Users: " ++ model.requestedUsername)
        , br [] []
        , viewUser model
        ]



-- DECODERS


userDecoder : Decoder User
userDecoder =
    field "data"
        (Decode.succeed User
            |> required "id" int
            |> required "fullName" string
            |> required "username" string
        )
