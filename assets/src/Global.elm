module Global exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    )

import Generated.Routes as Routes exposing (Route)
import Ports


type alias Flags =
    ()


type alias Model =
    { menuOpen : Bool
    }


type Msg
    = MobileMenuClick


type alias Commands msg =
    { navigate : Route -> Cmd msg
    }


init : Commands msg -> Flags -> ( Model, Cmd Msg, Cmd msg )
init _ _ =
    ( { menuOpen = False }
    , Cmd.none
    , Ports.log "Hello!"
    )


update : Commands msg -> Msg -> Model -> ( Model, Cmd Msg, Cmd msg )
update _ msg model =
    case msg of
        MobileMenuClick ->
            ( { model | menuOpen = not model.menuOpen }
            , Cmd.none
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
