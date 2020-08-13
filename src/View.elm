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
import Css exposing (..)
import Css.Transitions as Transitions
import Css.Media as Media
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
  , catalog : CatalogC
  }


type alias Theme =
  { primary        : String  -- hex
  , primaryLight   : String  -- hex
  , primaryDark    : String  -- hex
  , secondary      : String  -- hex
  , secondaryLight : String  -- hex
  , secondaryDark  : String  -- hex
  , danger         : String  -- hex
  , dangerLight    : String  -- hex
  , onDangerLight  : String  -- hex
  , dangerDark     : String  -- hex
  , onDangerDark   : String  -- hex
  , background     : String  -- hex
  , contentBg      : String  -- hex
  , onPrimary      : String  -- hex
  , onSecondary    : String  -- hex
  , onSurface      : String  -- hex
  , darkGrey       : String  -- hex
  , lightGrey      : String  -- hex
  , lighterGrey    : String  -- hex
  , lightGreen     : String  -- hex
  }


type alias CatalogC =
  { cartToggled  : Bool
  , itemSettings : CatalogItemSettings
  , theme        : Theme
  , spacing      : Spacing
  }


type alias Spacing =
  { base     : Float
  , s1       : Float
  , s2       : Float
  , s3       : Float
  , s4       : Float
  , s5       : Float
  , s6       : Float
  , s7       : Float
  , s8       : Float
  , s9       : Float
  }


type alias CatalogItemSettings =
  { maxWidth               : Float      -- px
  , nameLinesMax           : Int
  , fontSize               : Float      -- px
  , priceBlockHeight       : Float      -- px
  , liftAnimationDuration  : Float      -- ms
  , theme                  : Theme
  , spacing                : Spacing
  }


type alias HeaderC =
  { navbar      : NavbarC
  , navdrawer   : NavdrawerC
  , cartdrawer  : CartdrawerC
  }


type NavbarC = NavbarC


type NavdrawerC = NavdrawerC Bool (List NavItem)


--                             toggled 
type CartdrawerC = CartdrawerC Bool     Bool


type alias NavItem =
  { label : String, value : String, active : Bool }



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

{-| produce a view for the given app
-}
app : App.Model -> Model
app appModel = 
  let cartToggled = False
      header =
        { navdrawer =
            NavdrawerC
              False
              [ { label = "test1"
                , value = "test"
                , active = False
                }
              ]
        , navbar = NavbarC
        , cartdrawer = CartdrawerC cartToggled True
        }

      base = 20
      spacing =
       { base     = base
       , s1       = base * 0.5
       , s2       = base * 1.0
       , s3       = base * 1.5
       , s4       = base * 2.0
       , s5       = base * 2.5
       , s6       = base * 3.0
       , s7       = base * 3.5
       , s8       = base * 4.0
       , s9       = base * 4.5
       }

      theme =
        { primary        = "00bfa5"
        , primaryLight   = "5df2d6"
        , primaryDark    = "008e76"
        , secondary      = "1a237e"
        , secondaryLight = "534bae"
        , secondaryDark  = "000051"
        , danger         = "d50000"
        , dangerLight    = "ff5131"
        , onDangerLight  = "000"
        , dangerDark     = "9b0000"
        , onDangerDark   = "fff"
        , background     = "fff"
        , contentBg      = "eaeded"
        , onPrimary      = "fff"
        , onSecondary    = "fff"
        , onSurface      = "041e42"
        , lightGrey      = "77859940"
        , darkGrey       = "738195"
        , lighterGrey    = "f5f6f7"
        , lightGreen     = "76ff03"
        }

      itemSettings =
        { maxWidth               = 200
        , nameLinesMax           = 3
        , fontSize               = 14
        , priceBlockHeight       = 32
        , liftAnimationDuration  = 400
        , theme                  = theme
        , spacing                = spacing
        }

      catalog =
        { cartToggled  = cartToggled
        , itemSettings = itemSettings
        , theme        = theme
        , spacing      = spacing
        }

  in ItemBrowser { header = header, catalog = catalog }


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
          let header = toggleCartdrawer modelView.header
              modelView_ =
                { modelView
                | header = header
                , catalog =
                    toggleCartGutter header modelView.catalog
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


toggleCartGutter : HeaderC -> CatalogC -> CatalogC
toggleCartGutter header catalog =
  let (CartdrawerC toggled _) = header.cartdrawer
  in { catalog | cartToggled = toggled }


toggleCartdrawerSubTotal : HeaderC -> HeaderC
toggleCartdrawerSubTotal header =
  let (CartdrawerC toggled subTotalCollapsed) = header.cartdrawer
      cartdrawer = CartdrawerC toggled (not subTotalCollapsed)

  in { header | cartdrawer = cartdrawer }


floatToMoney : Float -> String
floatToMoney price = "$ " ++ Round.round 2 price


-- RENDERS

renderItemBrowser : App.Model -> Model -> Html Msg
renderItemBrowser app_ model =
  case model of
    ItemBrowser browserView ->
      let header = browserView.header
          catalog = browserView.catalog
      in
        div
          [ ViewStyle.appContainer ]
          [ renderHeader header.navbar header.navdrawer
          , UseCase.viewCart (cartView header.cartdrawer)
                             (App.store app_)
          , renderAddBanner
          , UseCase.browseCatalog (catalogView catalog)
                                  (App.store app_)
          , renderPagination
          , renderFooter
          ]


renderPagination : Html Msg
renderPagination =
  div
    [ ViewStyle.paginationWrapper ]
    [ div
        [ ViewStyle.pagination ]
        [ button
            [ ViewStyle.pagination__prev ]
            [ i
              [ ViewStyle.pagination__navIcon
              , class "material-icons"
              ]
              [ text "arrow_back" ]
            ]
        , span
            [ ViewStyle.pagination__ellipsisPrev ]
            [ text "..." ]
        , div
            [ ViewStyle.pagination__pageWrapper ]
            (List.map
              (\i ->
                button
                  (if i == 1
                    then [ ViewStyle.pagination__currentPage ]
                    else [ ViewStyle.pagination__page ]
                  )
                  [ text (String.fromInt i) ]
              ) (List.range 1 20)
            )
        , span
            [ ViewStyle.pagination__ellipsisNext ]
            [ text "..." ]
        , button
            [ ViewStyle.pagination__next ]
            [ i
              [ ViewStyle.pagination__navIcon
              , class "material-icons"
              ]
              [ text "arrow_forward" ]
            ]
        ]
    ]


renderFooter : Html Msg
renderFooter =
  div
    [ ViewStyle.footer ]
    []


renderAddBanner : Html Msg
renderAddBanner =
  div
    [ ViewStyle.addBanner ]
    []


cartView : CartdrawerC -> UseCase.CartView (Html Msg)
cartView cartdrawer
         saleSubTotal
         taxPct
         saleTax
         saleTotal
         totalSavings
         cartEntries
  = let (CartdrawerC toggled subTotalToggled) = cartdrawer
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
                [ -- button
                  --   [ ViewStyle.btnFilledPrimaryBlock
                  --   ]
                  --   [ text "proceed check out" ]
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
                            [ text (floatToMoney saleSubTotal)
                            ]
                        ]
                    , renderShoppingCart subTotalToggled cartEntries
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
                                  (String.fromFloat taxPct) ++
                                  "%)"
                                )
                            ]
                        , span
                            [ ViewStyle.cartdrawerContentValue ]
                            [ text (floatToMoney saleTax)
                            ]
                        ]
                    , div
                        [ ViewStyle.cartdrawerTotal ]
                        [ span
                            [ ViewStyle.cartdrawerContentLabel ]
                            [ text "total" ]
                        , span
                            [ ViewStyle.cartdrawerContentValue ]
                            [ text (floatToMoney saleTotal)
                            ]
                        ]
                    , div
                        [ ViewStyle.cartdrawerSavings ]
                        [ span
                            [ ViewStyle.cartdrawerContentLabel ]
                            [ text "total savings" ]
                        , span
                            [ ViewStyle.cartdrawerContentValue ]
                            [ text (floatToMoney totalSavings)
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


renderShoppingCart : Bool -> List UseCase.EntryViewD -> Html Msg
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


renderCartEntry : UseCase.EntryViewD -> Html Msg
renderCartEntry entry =
  let item = entry.item
  in
  div
    [ ViewStyle.cartdrawerEntry ]
    [ img 
        [ src item.image
        , ViewStyle.cartEntryImg
        ] []
    , div
        [ ViewStyle.cartEntryDetails
        ]
        [ renderEntryName (item.name ++ " by " ++ item.brand)
        , span
            [ ViewStyle.cartEntryVariant ]
            [ text (item.variant ++ ", ") ]
        , span
            [ ViewStyle.cartEntrySize ]
            [ text item.size ]
        , div
            [ ViewStyle.qtyWrapper ]
            [ button
                [ ViewStyle.qtyBtnDec
                , onClick <| AppMsg (App.RemoveItemFromCart item.id)
                ]
                [ text "-" ]
            , span
                [ ViewStyle.qtyVal ]
                [ text (String.fromInt entry.qty) ]
            , button
                [ ViewStyle.qtyBtnInc
                , onClick <| AppMsg (App.AddItemToCart item.id)
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


catalogView : CatalogC -> List UseCase.ItemViewD -> Html Msg
catalogView catalog data =
  let cartToggled = catalog.cartToggled
      itemSettings = catalog.itemSettings
  in
  div
    [ ViewStyle.catalogContainer cartToggled ]
    (List.map (renderCatalogItem itemSettings) data)


renderCatalogItem : CatalogItemSettings -> UseCase.ItemViewD -> Html Msg
renderCatalogItem settings item =
  let itemStyle =
        css
          [ backgroundColor (hex settings.theme.background)
          , padding (px settings.spacing.s1)
          , paddingBottom (px settings.spacing.s2)
          , lineHeight (px settings.spacing.s2)
          , hover [ ViewStyle.elevation6Style ]
          , Transitions.transition
              [ Transitions.boxShadow settings.liftAnimationDuration ]
          ]

      wrapperStyle =
        css
          [ backgroundColor transparent
          , maxWidth (px (settings.maxWidth))
          , width (pct 50)
          , boxSizing borderBox
          , paddingBottom (px settings.spacing.s1)
          , paddingRight (px (0.5 * settings.spacing.s1))
          , paddingLeft (px (0.5 * settings.spacing.s1))



          -- , Media.withMedia
          --     [ Media.only Media.screen [ Media.minWidth (px 1440) ] ]
          --     [ paddingLeft (px 10)
          --     , paddingRight (px 10)
          --     ]
          -- , Media.withMedia
          --     [ Media.only Media.screen [ Media.minWidth (px 1180) ] ]
          --     [ width (vw 17.2)
          --     ]
          -- , Media.withMedia
          --     [ Media.only Media.screen [ Media.minWidth (px 920) ] ]
          --     [ width (vw 20.6)
          --     , paddingLeft (px 20)
          --     , paddingRight (px 10)
          --     , paddingBottom (px 20)
          --     , marginRight (px -10)
          --     ]
          -- , Media.withMedia
          --     [ Media.only Media.screen [ Media.minWidth (px 720) ] ]
          --     [ ViewStyle.pb1Style
          --     , paddingLeft (px 16)
          --     , paddingRight (px 8)
          --     , marginRight (px -8)
          --     , width (vw 25.6)
          --     , maxWidth (px 200)
          --     ]
          -- , Media.withMedia
          --     [ Media.only Media.screen [ Media.minWidth (px 480) ] ]
          --     [ width (vw 33.5)
          --     ]
          ]

      discountBannerStyle =
        css
          [ display block
          , textAlign center
          , width (px 138)
          , height (px 18)
          , backgroundColor (hex settings.theme.primary)
          , color (hex settings.theme.onPrimary)
          , top (px 0)
          , position absolute
          , transforms
              [ (rotate (deg -45))
              , (translateX (px -41))
              , (translateY (px -24))
              ]
          , fontWeight bold
          , fontSize (px 12)
          , textTransform uppercase
          ]

      imgWrapperStyle = css [ position relative, overflow hidden ]

      imgStyle =
        css
          [ width (pct 100)
          , display block
          , height auto
          ]

      showImageWith_DiscountBanner =
        [ div
            [ discountBannerStyle ]
            [ text <| (String.fromInt item.discountPct) ++ "% off" ]
        , img [ src item.image, imgStyle ] []
        ]

      showImage =
        [ img [src item.image, imgStyle] [] ]

      image = 
        if item.discountPct > 0
          then showImageWith_DiscountBanner
          else showImage

      priceBlockStyle =
        css
          [ ViewStyle.pt1Style
          , height <| px (2 * settings.spacing.s2)
          , displayFlex
          , flexWrap wrap
          , alignItems flexEnd
          ]

      wasPriceStyle =
        css
          [ fontSize (px 14)
          , fontWeight bold
          , color (hex settings.theme.lightGrey)
          , width (pct 100)
          , textAlign center
          , textDecoration lineThrough
          ]

      nowPriceStyle =
        css
          [ fontSize (px 14)
          , fontWeight bold
          , color (hex settings.theme.secondary)
          , textAlign center
          , width (pct 100)
          , lineHeight (px settings.spacing.s2)
          ]

      showListAndSalePrice =
        [ div [ wasPriceStyle ] [ text (floatToMoney item.listPrice) ]
        , div [ nowPriceStyle ] [ text (floatToMoney item.salePrice) ]
        ]

      showListPrice =
        [ div [ nowPriceStyle ] [ text (floatToMoney item.listPrice) ]
        ]

      priceBlock =
        if item.salePrice < item.listPrice
          then showListAndSalePrice
          else showListPrice

      ctaBlockStyle = css [ paddingTop (px settings.spacing.s2) ]

      btnStyle =
        css
          [ ViewStyle.btnStyle
          , ViewStyle.btnFilledSecondaryStyle
          , borderColor (hex settings.theme.primary)
          , color (hex settings.theme.onPrimary)
          , ViewStyle.btnMediumStyle
          , borderStyle none
          , display block
          , width (pct 100)
          , fontSize (px 14)
          , fontWeight bold
          ]
        
      btn__iconStyle =
        css
          [ fontSize (px 16)
          , display inlineBlock
          , marginLeft (px settings.spacing.s1)
          , verticalAlign bottom
          ]

      ctaBlock =
        [ button
            [ btnStyle, onClick <| AppMsg (App.AddItemToCart item.id) ]
            [ text "add"
            , i [ btn__iconStyle , class "material-icons" ]
                [ text "add_shopping_cart" ]
            ]
        ]

      nameStyle =
        css
          [ fontSize (px 14)
          , fontWeight bold
          , textTransform capitalize
          , color (hex settings.theme.secondary)
          , paddingBottom (px settings.spacing.s1)
          , height <| px
              ((toFloat settings.nameLinesMax) * settings.spacing.s2)
          , textDecoration none
          , display block
          ]

  in
    div
      [ wrapperStyle ]
      [ div
          [ itemStyle ]
          [ a [ href "#" , nameStyle ] [ text item.name ]
          , div [ imgWrapperStyle ] image
          , div [ priceBlockStyle ] priceBlock
          , div [ ctaBlockStyle ] ctaBlock
          ]
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
    [ div
        [ ViewStyle.navbarContentWrapper ]
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
    ]


