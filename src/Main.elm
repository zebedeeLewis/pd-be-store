
module Main exposing (main)

import Browser
import Browser.Events as E
import Task
import Either
import Browser.Dom as BrowserDom
import Html exposing (Html, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)

import Material.Theme as Theme
import Material.Button as Button
import Material.Typography as Typography
import Material.TopAppBar as TopAppBar
import Material.IconButton as IconButton
import Material.Elevation as Elevation
import Material.Drawer.Modal as ModalDrawer
import Material.Drawer.Dismissible as Drawer
import Material.List as List
import Material.List.Item as ListItem
import Material.List.Divider as ListDivider


-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

int_min : Int
int_min = negate (2^31)



-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

{-| representation of various screen width ranges (in px).
-}
type ScreenSize
  = XSmall         -- < 600px
  | Small          -- [600px, 1023px)
  | Medium         -- (1024px, 1439px)
  | Large          -- (1440px, 1919px)
  | XLarge         -- > 1920
  | Undetermined


type DrawerState
  = Shown
  | Hidden
  | Unset


type alias Model = 
  { drawerState : DrawerState
  , viewport: Maybe BrowserDom.Viewport
  }


type Msg
  = ToggleDrawer
  | QueryViewport
  | GotViewport BrowserDom.Viewport



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------


subscriptions : Model -> Sub Msg
subscriptions _ = E.onResize (\_ _ -> QueryViewport)


invertDrawerState : DrawerState -> DrawerState
invertDrawerState state =
  case state of
    Unset -> Unset
    Shown -> Hidden
    Hidden -> Shown


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of 
    ToggleDrawer ->
      ( { model
        | drawerState = invertDrawerState model.drawerState
        }
      , Cmd.none
      )

    GotViewport vp ->
      ( { model
        | viewport = Just vp
        , drawerState =
            if isXSScreen (Just vp) then Hidden else Shown
        }
      , Cmd.none
      )

    QueryViewport ->
      ( model , Task.perform GotViewport BrowserDom.getViewport)


topNav : Html Msg
topNav =
  TopAppBar.regular
    ( TopAppBar.config
        |> TopAppBar.setDense True
        |> TopAppBar.setAttributes [Elevation.z2]
    )

    [ TopAppBar.row []
        [ TopAppBar.section [ TopAppBar.alignStart ]
            [ IconButton.iconButton
                (IconButton.config
                  |> IconButton.setOnClick ToggleDrawer
                  |> IconButton.setAttributes
                       [ TopAppBar.navigationIcon, Theme.onPrimary ]
                )
                "menu"
            , Html.span [ TopAppBar.title, Theme.onPrimary ]
                [ text "Title" ]
            ]
        ]
    ]


drawerConfig : Model -> Drawer.Config Msg
drawerConfig model =
  let
    drawerToggled = 
      if model.drawerState == Shown then True else False
  in
    Drawer.config
     |> Drawer.setOpen drawerToggled
     |> Drawer.setAttributes
          [ Elevation.z1
          ]


modalDrawerConfig : Model -> ModalDrawer.Config Msg
modalDrawerConfig model =
  let
    drawerToggled = 
      if model.drawerState == Shown then True else False
  in
    ModalDrawer.config
     |> ModalDrawer.setOpen drawerToggled
     |> ModalDrawer.setAttributes
          [ ]
    

drawerContent : Model -> Html Msg
drawerContent model = 
  Drawer.content []
    [ List.list 
        List.config
        ( ListItem.listItem ListItem.config
            [ text "Home" ]
        )
        [ ListItem.listItem ListItem.config
            [ text "login" ]
        , ListItem.listItem ListItem.config
            [ text "logout" ]
        , ListDivider.listItem ListDivider.config
        ]
    ]


drawerHeader : Model -> Html Msg
drawerHeader model = 
  Drawer.header []
    [ Html.h3 [ Drawer.title, Theme.primary ]
        [ text "Title" ]
    , Html.h6 [ Drawer.subtitle, Theme.secondary ]
        [ text "Subtitle" ]
    ]


navDrawer : Model -> Html Msg
navDrawer model = 
  if isXSScreen model.viewport then
    ModalDrawer.drawer
      ( modalDrawerConfig model )
      [ drawerHeader model
      , drawerContent model
      ]
  else
    Drawer.drawer
      ( drawerConfig model )
      [ drawerHeader model
      , drawerContent model
      ]


{-| produce the smallest possible viewport width for the given
screen size.
-}
getMinScreenSize : ScreenSize -> Int
getMinScreenSize screenSize =
  case screenSize of
    XSmall -> int_min
    Small -> 600
    Medium -> 1024
    Undetermined -> 1024
    Large -> 1440
    XLarge -> 1920


isXSScreen : Maybe BrowserDom.Viewport -> Bool
isXSScreen viewport = 
  case viewport of
    Nothing ->
      False

    Just vp ->
      let
        vpWidth = vp.viewport.width
      in
        if round vpWidth < (getMinScreenSize Small) then
          True
        else
          False


view : Model -> Html Msg
view model =
  Html.div
    [ style "display" "flex"
    , style "flex-flow" "row nowrap"
    , style "min-height" "100vh"
    , Theme.background
    ]
    (
      [ navDrawer model ]
      ++
      ( if isXSScreen model.viewport then
          [ ModalDrawer.scrim [ onClick ToggleDrawer ] [] ]
        else
          []
      )
      ++
      [ Html.div
          ( if isXSScreen model.viewport then
              []
            else
              [ Drawer.appContent ]
          )
          [ topNav
          , text "main content"
          ]
      ]
    )


init : () -> (Model, Cmd Msg)
init _ =
  ( { drawerState = Unset
    , viewport = Nothing
    }
  , Task.perform GotViewport BrowserDom.getViewport
  )


main : Program () Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
    
