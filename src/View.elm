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
import Html.Styled.Attributes exposing
  (id, placeholder, value, type_, class, css, href, src, style)

import Material.IconButton as IconButton
import Material.TopAppBar as TopAppBar

import Item
import ViewStyle


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
  = ToggleNavDrawer
  | ToggleCartDrawer


type Component
  = Navbar NavbarC


type NavbarC = NavbarC




-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

{-| TODO!!!
-}
update : Msg -> Model -> Model
update msg model = model


-- RENDERS

{-| TODO!!! -}
renderItemBrowser : Model -> List Item.BriefDataR -> Html Msg
renderItemBrowser model items =
 div
   []
   [ renderHeader
   ]


renderHeader :  Html Msg
renderHeader =
  div
    []
    [ renderNavbar NavbarC
    ]


renderNavbar : NavbarC -> Html Msg
renderNavbar navbar =
  div
    [ class "elevation2"
    , ViewStyle.navbar
    ]
    [ fromUnstyled
        (IconButton.iconButton
          ( IconButton.config
           |> IconButton.setOnClick ToggleNavDrawer
           |> IconButton.setAttributes
                [ TopAppBar.navigationIcon
                ]
          )
          "menu")
    , div
        [ ViewStyle.logo
        ]
        [ text "Logo"
        ]
    , div
        [ ViewStyle.navbarCartToggle ]
        [ fromUnstyled
            (IconButton.iconButton
              ( IconButton.config
               |> IconButton.setOnClick ToggleCartDrawer
               |> IconButton.setAttributes
                    [ TopAppBar.navigationIcon
                    ]
              )
              "shopping_cart")
        ]
    ]


