module Layouts.Locations exposing (view)

import Html exposing (Html)
import Utils.Spa as Spa


view : Spa.LayoutContext msg -> Html msg
view { page } =
    page
