module View exposing
  -- Test Exports, uncomment the exposing block below for
  -- testing.
  (..)
 
  -- Production Exports, uncomment the exposing block below for
  -- production and comment out the "Test Exports" above.
  -- (
  -- )


import Html
import Html.Styled exposing
  ( Html , br , h1 , h2, input, a, button, span, ul, li, div, text
  , fromUnstyled, toUnstyled
  )

import App


-----------------------------------------------------------------------
-- CONSTANT DEFINITIONS
-----------------------------------------------------------------------



-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

type Model
  = Loading
  | ItemBrowser (List Component)


type Msg
  = UpdateApp App.Msg


type Component = TempCmpnt



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

{-| produce an application view
TODO!!!
-}
renderApp : Model -> App.Model -> Html.Html Msg
renderApp viewModel appModel =
    toUnstyled <| div [] []


{-| TODO!!!
-}
update : Msg -> Model -> Model
update msg model = model

