module Main exposing (main)

import Browser
import Http exposing (Error(..))
import Html exposing (Html, section, div, form, input, a, i, p, text, span)
import Html.Attributes exposing (id, type_, class, placeholder, value)
import Html.Events exposing (onInput)

-- MODEL
type alias SearchResult =
    { id: String
    , name: String
    }

type alias SearchModel =
    { term: String
    , selected: String
    , options: List SearchResult
    }

initialModel : SearchModel
initialModel =
    { term = ""
    , selected = "abc"
    , options = [{ id = "abc", name = "Artjom Vassiljev"}, { id = "abd", name = "Anna Kamenskaja"}]
    }

-- UPDATE
url : String
url
    = "http://localhost:5000/api/users/?q="

type ApiResponse
    = SearchQueryRequest
    | SearchQueryResponse (Result Http.Error String)

type InputMsg
    = SearchTerm String
    | SelectUser SearchResult

update : InputMsg -> SearchModel -> SearchModel
update message searchModel =
    case message of
        SearchTerm term ->
            { searchModel | term = term }

        SelectUser user ->
            { searchModel | selected = user.id }

-- VIEW
view : SearchModel -> Html InputMsg
view search =
    section [ class "section" ]
        [ div [ class "container" ]
            [ form []
                [ div [ class "dropdown is-active" ]
                    [ div [ class "dropdown-trigger" ]
                        [ div [ class "field" ]
                            [ p [ class "control is-expanded has-icons-right" ]
                                [ input [ class "input", type_ "search", placeholder "Search...", value search.term, onInput SearchTerm ] []
                                ,  span [ class "icon is-small is-right" ]
                                    [ i [ class "fas fa-search" ] [] ]
                                ]
                            ]
                        ]
                    , div [ class "dropdown-menu" ]
                        [ div [ class "dropdown-content" ]
                            [ a [ class "dropdown-item" ] [ text "Item #1" ]
                            , a [ class "dropdown-item" ] [ text "Item #2" ]
                            , a [ class "dropdown-item" ] [ text "Item #3" ]
                            ]
                        ]
                    ]
                ]
            ]
        ]

main : Program () SearchModel InputMsg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
