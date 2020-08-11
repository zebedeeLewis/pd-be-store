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
  , fromUnstyled, toUnstyled, img, i
  )
import Html.Styled.Attributes exposing
  (id, placeholder, value, type_, class, css, href, src, style
  , attribute
  )
import Html.Styled.Events exposing (onClick)

import Material.IconButton as IconButton
import Material.TopAppBar as TopAppBar
import Material.Icon as Icon
import Round

import Item
import ShoppingList
import UseCase
import ViewStyle
import App


-----------------------------------------------------------------------
-- CONSTANT DEFINITIONS
-----------------------------------------------------------------------



-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

type Model
  = ItemBrowser ItemBrowserV


type Msg
  = ToggleNavdrawer
  | ToggleCartdrawer
  | ToggleCartdrawerSubTotal
  | AppMsg App.Msg
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


type NavbarC = NavbarC


type NavdrawerC = NavdrawerC Bool (List NavItem)


type CartdrawerC = CartdrawerC Bool Bool


type alias NavItem =
  { label : String, value : String, active : Bool }



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

{-| produce a view for the given app
-}
app : App.Model -> Model
app appModel = 
  let header =
        { navdrawer =
            NavdrawerC
              False
              [ { label = "test1"
                , value = "test"
                , active = False
                }
              ]
        , navbar = NavbarC
        , cartdrawer = CartdrawerC False True
        }
  in
    case appModel of
      App.ItemBrowser _ -> ItemBrowser { header = header }


update : Msg -> Model -> Model
update msg model =
  case msg of
    ToggleNavdrawer ->
      case model of
        ItemBrowser modelView ->
          let modelView_ =
                { modelView
                | header = toggleNavdrawer modelView.header
                }
          in ItemBrowser modelView_

    ToggleCartdrawer ->
      case model of
        ItemBrowser modelView ->
          let modelView_ =
                { modelView
                | header = toggleCartdrawer modelView.header
                }
          in ItemBrowser modelView_

    ToggleCartdrawerSubTotal ->
      case model of
        ItemBrowser modelView ->
          let modelView_ =
                { modelView
                | header = toggleCartdrawerSubTotal modelView.header
                }
          in ItemBrowser modelView_

    AppMsg _ -> model

    NoOp -> model


isAppMsg : Msg -> Bool
isAppMsg msg =
  case msg of
    AppMsg _ -> True
    _ -> False


unwrapAppMsg : Msg -> Maybe App.Msg
unwrapAppMsg msg =
  case msg of
    AppMsg appMsg -> Just appMsg
    _ -> Nothing


toggleNavdrawer : HeaderC -> HeaderC
toggleNavdrawer header = 
  let (NavdrawerC toggled navItems) = header.navdrawer
      navdrawer = NavdrawerC (not toggled) navItems

  in { header | navdrawer = navdrawer }


toggleCartdrawer : HeaderC -> HeaderC
toggleCartdrawer header =
  let (CartdrawerC toggled subTotalCollapsed) = header.cartdrawer
      cartdrawer = CartdrawerC (not toggled) subTotalCollapsed

  in { header | cartdrawer = cartdrawer }


toggleCartdrawerSubTotal : HeaderC -> HeaderC
toggleCartdrawerSubTotal header =
  let (CartdrawerC toggled subTotalCollapsed) = header.cartdrawer
      cartdrawer = CartdrawerC toggled (not subTotalCollapsed)

  in { header | cartdrawer = cartdrawer }


floatToMoney : Float -> String
floatToMoney price = "$ " ++ Round.round 2 price


-- RENDERS

renderItemBrowser : App.Model -> Model -> Html Msg
renderItemBrowser appModel model =
  let cart = App.cart appModel
      items = App.itemSet appModel
  in
  case model of
    ItemBrowser browserView ->
      let header = browserView.header
      in
        div
          [ ViewStyle.appContainer ]
          [ renderHeader header.navbar header.navdrawer
          , renderCartdrawer cart header.cartdrawer
          , renderItemBrowserContent items model
          ]


renderCartdrawer : ShoppingList.Model -> CartdrawerC -> Html Msg
renderCartdrawer cart cartdrawer =
  let (CartdrawerC toggled subTotalToggled) = cartdrawer
  in
    div
      [ if toggled 
          then ViewStyle.cartdrawerShown
          else ViewStyle.cartdrawerHidden
      ]
      [ div
          [ ]
          [ div
              [ ViewStyle.drawerTopBar ]
              [ div
                  [ ViewStyle.drawerTopBarTitle ]
                  [ text "shopping Cart" ]
              , button
                  [ ViewStyle.btnCloseCart
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
              [ ViewStyle.cartdrawerActionLine ]
              [ button
                  [ ViewStyle.btnFilledPrimaryBlock
                  ]
                  [ text "proceed check out" ]
              ]
          , div
              [ ViewStyle.cartdrawerContent
              ]
              [ div
                  [ ViewStyle.cartdrawerSummary ]
                  [ div
                      [ ViewStyle.cartdrawerDiscounts ]
                      [ span
                          [ ViewStyle.cartdrawerContentLabel ]
                          [ button
                              [ ViewStyle.btnCollapse
                              , onClick ToggleCartdrawerSubTotal
                              ]
                              [ text "sub-total"
                              , i [ class "material-icons"
                                  , ViewStyle.iconCollapse
                                  ]
                                  [ text
                                      (if subTotalToggled
                                        then "expand_less"
                                        else "expand_more")
                                  ]
                              ]
                          ]
                      , span
                          [ ViewStyle.cartdrawerContentValue ]
                          [ text
                              <| floatToMoney
                                   (ShoppingList.saleTotal cart)
                          ]
                      ]
                  , UseCase.viewListContent
                      (renderShoppingCart subTotalToggled)
                      cart
                  -- , div
                  --     [ ViewStyle.cartdrawerDiscounts ]
                  --     [ span
                  --         [ ViewStyle.cartdrawerContentLabel ]
                  --         [ button
                  --             [ ViewStyle.btnDiscount ]
                  --             [ text "discounts"
                  --             , fromUnstyled
                  --                 (Icon.icon
                  --                   [ Html.Attributes.style
                  --                       "font-size" "13px"
                  --                   , Html.Attributes.style
                  --                       "vertical-align" "text-bottom"
                  --                   , Html.Events.onClick
                  --                       NoOp
                  --                   ]
                  --                   "keyboard_arrow_down")
                  --             ]
                  --         ]
                  --     , span
                  --         [ ViewStyle.cartdrawerContentValue ]
                  --         [ text "$35.00" ]
                  --     ]
                  -- , div 
                  --     [ ViewStyle.cartdrawerDiscountPanel ]
                  --     [ div 
                  --         [ ViewStyle.cartdrawerDiscountItem ]
                  --         [ div
                  --             [ ViewStyle.cartdrawerDiscountItemLabel ]
                  --             [ a
                  --                 [ ViewStyle.cartdrawerDiscountLabelLink
                  --                 , href "#"
                  --                 ]
                  --                 [ text "discount 1" ]
                  --             ]
                  --         , div
                  --             [ ViewStyle.cartdrawerDiscountPct ]
                  --             [ text "15%"]
                  --         , div
                  --             [ ViewStyle.cartdrawerDiscountAction ]
                  --             [ button
                  --                 [ ViewStyle.cartdrawerApplyDiscountBtn
                  --                 , onClick NoOp
                  --                 ]
                  --                 [ fromUnstyled
                  --                     (Icon.icon
                  --                       [ Html.Attributes.style
                  --                           "font-size" "14px"
                  --                       ]
                  --                       "check")
                  --                 ]
                  --             ]
                  --         , div
                  --             [ ViewStyle.cartdrawerAppliedDiscountItemVal ]
                  --             [ text "-$15.00"]
                  --         ]
                  --     , div 
                  --         [ ViewStyle.cartdrawerDiscountItem ]
                  --         [ div
                  --             [ ViewStyle.cartdrawerDiscountItemLabel ]
                  --             [ a
                  --                 [ ViewStyle.cartdrawerDiscountLabelLink
                  --                 , href "#"
                  --                 ]
                  --                 [ text "discount 2" ]
                  --             ]
                  --         , div
                  --             [ ViewStyle.cartdrawerDiscountPct ]
                  --             [ text "10%"]
                  --         , div
                  --             [ ViewStyle.cartdrawerDiscountAction ]
                  --             [ button
                  --                 [ ViewStyle.cartdrawerRemoveDiscountBtn
                  --                 , onClick NoOp
                  --                 ]
                  --                 [ fromUnstyled
                  --                     (Icon.icon
                  --                       [ Html.Attributes.style
                  --                           "font-size" "14px"
                  --                       ]
                  --                       "close")
                  --                 ]
                  --             ]
                  --         , div
                  --             [ ViewStyle.cartdrawerDiscountItemVal ]
                  --             [ text "-$32.00"]
                  --         ]
                  --     , div 
                  --         [ ViewStyle.cartdrawerDiscountItem ]
                  --         [ div
                  --             [ ViewStyle.cartdrawerDiscountItemLabel ]
                  --             [ a
                  --                 [ ViewStyle.cartdrawerDiscountLabelLink
                  --                 , href "#"
                  --                 ]
                  --                 [ text "discount 3" ]
                  --             ]
                  --         , div
                  --             [ ViewStyle.cartdrawerDiscountPct ]
                  --             [ text "20%"]
                  --         , div
                  --             [ ViewStyle.cartdrawerDiscountAction ]
                  --             [
                  --             ]
                  --         , div
                  --             [ ViewStyle.cartdrawerAppliedDiscountItemVal ]
                  --             [ text "-$20.00"]
                  --         ]
                  --     ]
                  , div
                      [ ViewStyle.cartdrawerTax ]
                      [ span
                          [ ViewStyle.cartdrawerContentLabel ]
                          [ text 
                              ( "tax (" ++
                                (Round.round 2
                                  <| ShoppingList.tax cart) ++
                                "%)"
                              )
                          ]
                      , span
                          [ ViewStyle.cartdrawerContentValue ]
                          [ text 
                              <| floatToMoney
                                   (ShoppingList.taxedSaleTotal cart)
                          ]
                      ]
                  , div
                      [ ViewStyle.cartdrawerTotal ]
                      [ span
                          [ ViewStyle.cartdrawerContentLabel ]
                          [ text "total" ]
                      , span
                          [ ViewStyle.cartdrawerContentValue ]
                          [ text
                              <| floatToMoney
                                   (ShoppingList.saleTotal cart)
                          ]
                      ]
                  , div
                      [ ViewStyle.cartdrawerSavings ]
                      [ span
                          [ ViewStyle.cartdrawerContentLabel ]
                          [ text "total savings" ]
                      , span
                          [ ViewStyle.cartdrawerContentValue ]
                          [ text
                              <| floatToMoney
                                   (ShoppingList.calcSavings cart)
                          ]
                      ]
                  , div
                      [ ViewStyle.cartdrawerFinalCta ]
                      [ button
                          [ ViewStyle.btnFilledPrimary ]
                          [ text "proceed to checkout" ]
                      ]
                  ]
              ]
          ]
      ]


renderShoppingCart : Bool -> UseCase.ShoppingListView (Html Msg)
renderShoppingCart toggled entrySet =
  div
    [ if toggled
        then ViewStyle.toggledCartdrawerEntries
        else ViewStyle.cartdrawerEntries
    ]
    [ div
        []
        (List.map renderCartEntry entrySet)
    ]


renderCartEntry : UseCase.CartEntryViewR -> Html Msg
renderCartEntry entry =
  div
    [ ViewStyle.cartdrawerEntry ]
    [ img 
        [ src entry.image
        , ViewStyle.cartEntryImg
        ] []
    , div
        [ ViewStyle.cartEntryDetails
        ]
        [ renderEntryName (entry.name ++ " by " ++ entry.brand)
        , span
            [ ViewStyle.cartEntryVariant ]
            [ text (entry.variant ++ ", ") ]
        , span
            [ ViewStyle.cartEntrySize ]
            [ text entry.size ]
        , div
            [ ViewStyle.qtyWrapper ]
            [ button
                [ ViewStyle.qtyBtnDec
                , onClick <| AppMsg (App.DecEntryQty entry.id)
                ]
                [ text "-" ]
            , span
                [ ViewStyle.qtyVal ]
                [ text (String.fromInt entry.qty) ]
            , button
                [ ViewStyle.qtyBtnInc
                , onClick <| AppMsg (App.IncEntryQty entry.id)
                ]
                [ text "+" ]
            ]
        ]
    , div
        [ ViewStyle.cartEntryPrice ]
        <| [ div
               [ if entry.saleTotal < entry.listTotal
                   then ViewStyle.wasPrice
                   else ViewStyle.nowPrice
               ]
               [ text (floatToMoney entry.listTotal)
               ]
           ] ++ 
           if entry.saleTotal < entry.listTotal
             then [ div
                      [ ViewStyle.nowPrice ]
                      [ text (floatToMoney entry.saleTotal) ]
                  ]
             else []
    ]


renderEntryName : String -> Html Msg
renderEntryName name =
  div
    [ ViewStyle.cartEntryName ]
    [ let maybeFirstWord = List.head (String.words name)
      in
        case maybeFirstWord of
          Nothing -> text name
          Just firstWord ->
            if String.length firstWord > 17
              then text <| (String.dropRight 3 firstWord) ++ " ..."
            else if String.length name > 24
              then text <| (String.dropRight 3 name) ++ " ..."
              else text name
    ]


renderItemBrowserContent : Item.Set -> Model -> Html Msg
renderItemBrowserContent items model =
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
    [ ViewStyle.navbar
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


