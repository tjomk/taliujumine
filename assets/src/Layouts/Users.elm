module Layouts.Users exposing (view)

import Html exposing (..)
import Utils.Spa as Spa


view : Spa.LayoutContext msg -> Html msg
view { page } =
    page