module Layout exposing (view)

import Generated.Routes as Routes exposing (Route, routes)
import Html exposing (Html, a, div, img, nav, span, text)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Utils.Spa as Spa


view : Spa.LayoutContext msg -> Html msg
view { page, route } =
    div [ Attr.class "app" ]
        [ viewHeader route
        , page
        ]


viewHeader : Route -> Html msg
viewHeader currentRoute =
    nav [ Attr.class "navbar" ]
        [ div [ Attr.class "container " ]
            [ div [ Attr.class "navbar-brand" ]
                [ a
                    [ Attr.class "navbar-item"
                    , Attr.href (Routes.toPath routes.top)
                    ]
                    [ img [ Attr.src "https://bulma.io/images/bulma-logo.png", Attr.width 112, Attr.height 28 ] []
                    ]
                , span [ Attr.class "navbar-burger burger" ]
                    [ span [] []
                    , span [] []
                    , span [] []
                    ]
                ]
            , div [ Attr.class "navbar-menu" ]
                [ div [ Attr.class "navbar-start" ]
                    [ viewLink currentRoute ( "home", routes.top )
                    , viewLink currentRoute ( "nowhere", routes.notFound )
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
