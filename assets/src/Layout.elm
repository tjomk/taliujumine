module Layout exposing (view)

import Generated.Routes as Routes exposing (Route, routes)
import Global
import Html exposing (Html, a, div, img, nav, span, text)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Utils.Spa as Spa


getMobileMenuClasses : Bool -> String
getMobileMenuClasses menuOpen =
    if menuOpen then
        "navbar-burger burger is-active"

    else
        "navbar-burger burger"


getMenuItemClasses : Bool -> String
getMenuItemClasses menuOpen =
    if menuOpen then
        "navbar-menu is-active"

    else
        "navbar-menu"


view : Spa.LayoutContext msg -> Html msg
view { page, route, fromGlobalMsg, global } =
    div [ Attr.class "app" ]
        [ Html.map fromGlobalMsg (viewHeader route global)
        , page
        ]


viewHeader : Route -> Global.Model -> Html Global.Msg
viewHeader currentRoute model =
    let
        menuClasses =
            getMobileMenuClasses model.menuOpen

        itemClasses =
            getMenuItemClasses model.menuOpen
    in
    nav [ Attr.class "navbar" ]
        [ div [ Attr.class "container " ]
            [ div [ Attr.class "navbar-brand" ]
                [ a
                    [ Attr.class "navbar-item"
                    , Attr.href (Routes.toPath routes.top)
                    ]
                    [ img [ Attr.src "https://bulma.io/images/bulma-logo.png", Attr.width 112, Attr.height 28 ] []
                    ]
                , span [ Attr.class menuClasses, onClick Global.MobileMenuClick ]
                    [ span [] []
                    , span [] []
                    , span [] []
                    ]
                ]
            , div [ Attr.class itemClasses ]
                [ div [ Attr.class "navbar-start" ]
                    [ viewLink currentRoute ( "home", routes.top )
                    , viewLink currentRoute ( "nowhere", routes.notFound )
                    ]
                , div [ Attr.class "navbar-end" ]
                    [ div [ Attr.class "navbar-item" ]
                        [ div [ Attr.class "buttons" ]
                            [ a [ Attr.class "button is-primary" ] [ text "Sign up" ]
                            , a [ Attr.class "button is-light" ] [ text "Login" ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


viewLink : Route -> ( String, Route ) -> Html msg
viewLink currentRoute ( label, route ) =
    if currentRoute == route then
        span
            [ Attr.class "navbar-item" ]
            [ text label ]

    else
        a
            [ Attr.class "navbar-item"
            , Attr.href (Routes.toPath route)
            ]
            [ text label ]
