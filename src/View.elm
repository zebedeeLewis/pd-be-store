module View exposing
  -- Test Exports, uncomment the exposing block below for
  -- testing.
  (..)
 
  -- Production Exports, uncomment the exposing block below for
  -- production and comment out the "Test Exports" above.
  -- (
  -- )


import Html
import Html.Events
import Html.Attributes
import Html.Styled exposing
  ( Html , br , h1 , h2, input, a, button, span, ul, li, div, text
  , fromUnstyled, toUnstyled
  )
import Html.Styled.Attributes exposing
  (id, placeholder, value, type_, class, css, href, src, style)
import Html.Styled.Events exposing (onClick)

import Material.IconButton as IconButton
import Material.TopAppBar as TopAppBar
import Material.Icon as Icon

import Item
import ShoppingList
import ViewStyle


-----------------------------------------------------------------------
-- CONSTANT DEFINITIONS
-----------------------------------------------------------------------



-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

type Model
  = Loading LoadingV
  | ItemBrowser ItemBrowserV


type Msg
  = ToggleNavdrawer
  | ToggleCartdrawer
  | NoOp


type Component
  = Navbar NavbarC
  | Navdrawer NavdrawerC


type alias ItemBrowserV =
  { header : HeaderC
  }


type alias HeaderC =
  { navbar      : NavbarC
  , navdrawer   : NavdrawerC
  , cartdrawer  : CartdrawerC
  }


type alias LoadingV = { header : HeaderC }


type NavbarC = NavbarC


type NavdrawerC = NavdrawerC Bool (List NavItem)


type CartdrawerC = CartdrawerC Bool (ShoppingList.ShoppingList)


type alias NavItem =
  { label : String, value : String, active : Bool }



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

update : Msg -> Model -> Model
update msg model =
  case msg of
    ToggleNavdrawer ->
      case model of
        Loading modelView ->
          let modelView_ =
                { modelView
                | header = toggleNavdrawer modelView.header
                }
          in Loading modelView_

        ItemBrowser modelView ->
          let modelView_ =
                { modelView
                | header = toggleNavdrawer modelView.header
                }
          in ItemBrowser modelView_

    ToggleCartdrawer ->
      case model of
        Loading modelView ->
          let modelView_ =
                { modelView
                | header = toggleCartdrawer modelView.header
                }
          in Loading modelView_

        ItemBrowser modelView ->
          let modelView_ =
                { modelView
                | header = toggleCartdrawer modelView.header
                }
          in ItemBrowser modelView_

    NoOp -> model


toggleNavdrawer : HeaderC -> HeaderC
toggleNavdrawer header = 
  let (NavdrawerC toggled navItems) = header.navdrawer
      navdrawer = NavdrawerC (not toggled) navItems

  in { header | navdrawer = navdrawer }


toggleCartdrawer : HeaderC -> HeaderC
toggleCartdrawer header =
  let (CartdrawerC toggled cart) = header.cartdrawer
      cartdrawer = CartdrawerC (not toggled) cart

  in { header | cartdrawer = cartdrawer }


-- RENDERS

renderItemBrowser : Model -> List Item.BriefDataR -> Html Msg
renderItemBrowser model items =
  case model of
    ItemBrowser browserView ->
      let header = browserView.header
      in
        div
          [ ViewStyle.appContainer ]
          [ renderHeader header.navbar header.navdrawer
          , renderCartdrawer header.cartdrawer
          , renderItemBrowserContent model items
          ]

    _ ->
      div
        [ ViewStyle.appContainer ]
        [ text "Invalid Data passed to Item browser" ]


renderCartdrawer : CartdrawerC -> Html Msg
renderCartdrawer cartdrawer =
  let (CartdrawerC toggled cart) = cartdrawer
  in
    div
      [ if toggled 
          then ViewStyle.cartdrawerShown
          else ViewStyle.cartdrawerHidden
      , class "elevation1"
      ]
      [ div
          [ ViewStyle.cartdrawerContent
          ]
          [ div
              [ ViewStyle.drawerTopBar ]
              [ div
                  [ ViewStyle.drawerTopBarTitle ]
                  [ text "shopping Cart" ]
              , button
                  [ ViewStyle.btnClose
                  , onClick ToggleCartdrawer
                  ]
                  [ fromUnstyled
                      <| Icon.icon
                          [ Html.Attributes.style "font-size" "18px"
                          ]
                          "close"
                  ]
              ]
          , div
              [ ViewStyle.cartdrawerContent ]
              [ div
                  [ ViewStyle.cartdrawerSummary ]
                  [ div
                      [ ViewStyle.cartdrawerSubTotal ]
                      [ span
                          [ ViewStyle.cartdrawerContentLabel ]
                          [ text "sub-total" ]
                      , span
                          [ ViewStyle.cartdrawerContentValue ]
                          [ text "$300.00" ]
                      ]
                  , div
                      [ ViewStyle.cartdrawerDiscounts ]
                      [ span
                          [ ViewStyle.cartdrawerContentLabel ]
                          [ button
                              [ ViewStyle.btnSimple ]
                              [ text "discounts"
                              , fromUnstyled
                                  (Icon.icon
                                    [ Html.Attributes.style
                                        "font-size" "14px"
                                    , Html.Attributes.style
                                        "vertical-align" "text-bottom"
                                    , Html.Events.onClick
                                        NoOp
                                    ]
                                    "keyboard_arrow_down")
                              ]
                          ]
                      , span
                          [ ViewStyle.cartdrawerContentValue ]
                          [ text "$35.00" ]
                      ]
                  , div 
                      [ ViewStyle.cartdrawerDiscountPanel ]
                      [ div 
                          [ ViewStyle.cartdrawerDiscountItem ]
                          [ div
                              [ ViewStyle.cartdrawerDiscountItemLabel ]
                              [ a
                                  [ ViewStyle.cartdrawerDiscountLabelLink
                                  , href "#"
                                  ]
                                  [ text "discount 1" ]
                              ]
                          , div
                              [ ViewStyle.cartdrawerDiscountPct ]
                              [ text "15%"]
                          , div
                              [ ViewStyle.cartdrawerDiscountAction ]
                              [ button
                                  [ ViewStyle.cartdrawerApplyDiscountBtn
                                  , onClick NoOp
                                  ]
                                  [ fromUnstyled
                                      (Icon.icon
                                        [ Html.Attributes.style
                                            "font-size" "14px"
                                        ]
                                        "check")
                                  ]
                              ]
                          , div
                              [ ViewStyle.cartdrawerAppliedDiscountItemVal ]
                              [ text "-$15.00"]
                          ]
                      , div 
                          [ ViewStyle.cartdrawerDiscountItem ]
                          [ div
                              [ ViewStyle.cartdrawerDiscountItemLabel ]
                              [ a
                                  [ ViewStyle.cartdrawerDiscountLabelLink
                                  , href "#"
                                  ]
                                  [ text "discount 2" ]
                              ]
                          , div
                              [ ViewStyle.cartdrawerDiscountPct ]
                              [ text "10%"]
                          , div
                              [ ViewStyle.cartdrawerDiscountAction ]
                              [ button
                                  [ ViewStyle.cartdrawerRemoveDiscountBtn
                                  , onClick NoOp
                                  ]
                                  [ fromUnstyled
                                      (Icon.icon
                                        [ Html.Attributes.style
                                            "font-size" "14px"
                                        ]
                                        "close")
                                  ]
                              ]
                          , div
                              [ ViewStyle.cartdrawerDiscountItemVal ]
                              [ text "-$32.00"]
                          ]
                      , div 
                          [ ViewStyle.cartdrawerDiscountItem ]
                          [ div
                              [ ViewStyle.cartdrawerDiscountItemLabel ]
                              [ a
                                  [ ViewStyle.cartdrawerDiscountLabelLink
                                  , href "#"
                                  ]
                                  [ text "discount 3" ]
                              ]
                          , div
                              [ ViewStyle.cartdrawerDiscountPct ]
                              [ text "20%"]
                          , div
                              [ ViewStyle.cartdrawerDiscountAction ]
                              [
                              ]
                          , div
                              [ ViewStyle.cartdrawerAppliedDiscountItemVal ]
                              [ text "-$20.00"]
                          ]
                      ]
                  , div
                      [ ViewStyle.cartdrawerTax ]
                      [ span
                          [ ViewStyle.cartdrawerContentLabel ]
                          [ text "Tax (12%)" ]
                      , span
                          [ ViewStyle.cartdrawerContentValue ]
                          [ text "$300.00" ]
                      ]
                  , div
                      [ ViewStyle.cartdrawerTotal ]
                      [ span
                          [ ViewStyle.cartdrawerContentLabel ]
                          [ text "total" ]
                      , span
                          [ ViewStyle.cartdrawerContentValue ]
                          [ text "$300.00" ]
                      ]
                  , div
                      [ ViewStyle.cartdrawerActionLine ]
                      [ button
                          [ ViewStyle.btnPrimary ]
                          [ text "check out" ]
                      , button
                          [ ViewStyle.btnDangerCartdrawer ]
                          [ text "clear cart" ]
                      ]
                  ]
              , div
                  [ ViewStyle.cartdrawerItems ]
                  [ text "Todo..." ]
              ]
          ]
      ]


renderItemBrowserContent : Model -> List Item.BriefDataR -> Html Msg
renderItemBrowserContent model items =
  div
    []
    [
    ]


renderHeader : NavbarC -> NavdrawerC ->  Html Msg
renderHeader navbar navdrawer =
  div
    []
    [ renderNavbar navbar
    , renderNavdrawer navdrawer
    ]


renderNavdrawer : NavdrawerC -> Html Msg
renderNavdrawer navdrawer =
  let (NavdrawerC toggled navItems) = navdrawer
  in
    div
      [ if toggled 
          then ViewStyle.navdrawerShown
          else ViewStyle.navdrawerHidden
      ]
      [ div
          [ if toggled
              then ViewStyle.navdrawerShownScrim
              else ViewStyle.navdrawerHiddenScrim

          , onClick ToggleNavdrawer
          ] []
      , div
          [ if toggled
              then ViewStyle.navdrawerShownContent
              else ViewStyle.navdrawerHiddenContent
          ]
          [ div
              [ ViewStyle.drawerTopBar ]
              [ button
                  [ ViewStyle.btnClose
                  , onClick ToggleNavdrawer
                  ]
                  [ fromUnstyled
                      <| Icon.icon
                          [ Html.Attributes.style "font-size" "18px"
                          ]
                          "close"
                  ]
              ]
          , ul
              [ ViewStyle.navdrawerNav ]
              (List.map
                (\navItem ->
                  li
                    [ ]
                    [ a 
                       [ if navItem.active
                           then ViewStyle.navItemActive
                           else ViewStyle.navItem
                       ]
                       [ text <| navItem.label ]
                    ]
                ) navItems)
          ]
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
           |> IconButton.setOnClick ToggleNavdrawer
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
               |> IconButton.setOnClick ToggleCartdrawer
               |> IconButton.setAttributes
                    [ TopAppBar.navigationIcon
                    ]
              )
              "shopping_cart")
        ]
    ]


