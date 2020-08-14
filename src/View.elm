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
  = ItemBrowser Settings ItemBrowserV


type Msg
  = ToggleNavdrawer
  | ViewCart
  | ViewCartSubTotal
  | AppMsg App.Msg
  | NoOp


type Component
  = Navbar NavbarC
  | Navdrawer NavdrawerC


type alias ItemBrowserV =
  { header : HeaderC
  , catalog : Catalog
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
  , onBackground   : String  -- hex
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


type alias Breakpoint =
  { sm  : Float  -- px
  , md  : Float  -- px
  , lg  : Float  -- px
  , xl  : Float  -- px
  }


type alias Catalog =
  { cartToggled  : Bool
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


type alias Settings =
  { theme       : Theme
  , spacing     : Spacing
  , font        : Font
  , breakpoint  : Breakpoint
  }


type alias Font =
  { family      : String
  , size1       : Float  -- px
  , size2       : Float  -- px
  , lineHeight  : Float  -- px
  }


type alias HeaderC =
  { navbar      : NavbarC
  , navdrawer   : NavdrawerC
  , cartdrawer  : CartC
  }


type NavbarC = NavbarC


type NavdrawerC = NavdrawerC Bool (List NavItem)


type alias CartC =
  { toggled            : Bool
  , entriesShown  : Bool
  , spacing            : Spacing
  , theme              : Theme
  }


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
      base = 20

      spacing =
       { base  = base
       , s1    = base * 0.5
       , s2    = base * 1.0
       , s3    = base * 1.5
       , s4    = base * 2.0
       , s5    = base * 2.5
       , s6    = base * 3.0
       , s7    = base * 3.5
       , s8    = base * 4.0
       , s9    = base * 4.5
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
        , onBackground   = "4f4f4f"
        , onSecondary    = "fff"
        , onSurface      = "041e42"
        , lightGrey      = "77859940"
        , darkGrey       = "738195"
        , lighterGrey    = "f5f6f7"
        , lightGreen     = "76ff03"
        }

      cartdrawer =
        { toggled            = cartToggled
        , entriesShown  = True
        , spacing            = spacing
        , theme              = theme
        }

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
        , cartdrawer = cartdrawer
        }

      catalog = { cartToggled  = cartToggled }

      font =
        { family     = "Roboto, sans-serif"
        , size1      = 14
        , size2      = 13
        , lineHeight = base
        }

      breakpoint =
        { sm  = 600
        , md  = 960
        , lg  = 1280
        , xl  = 1920
        }

      settings =
        { spacing     = spacing
        , theme       = theme
        , font        = font
        , breakpoint  = breakpoint
        }

  in ItemBrowser settings { header = header, catalog = catalog }


update : Msg -> Model -> Model
update msg model =
  case msg of
    ToggleNavdrawer ->
      case model of
        ItemBrowser settings modelView ->
          let modelView_ =
                { modelView
                | header = toggleNavdrawer modelView.header
                }
          in ItemBrowser settings modelView_

    ViewCart ->
      case model of
        ItemBrowser settings modelView ->
          let header = toggleCartdrawer modelView.header
              modelView_ =
                { modelView
                | header = header
                , catalog =
                    toggleCartGutter header modelView.catalog
                }
          in ItemBrowser settings modelView_

    ViewCartSubTotal ->
      case model of
        ItemBrowser settings modelView ->
          let modelView_ =
                { modelView
                | header = toggleCartdrawerSubTotal modelView.header
                }
          in ItemBrowser settings modelView_

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
  let cartdrawer_ = header.cartdrawer
      toggled = cartdrawer_.toggled
      entriesShown = cartdrawer_.entriesShown
      cartdrawer = { cartdrawer_ | toggled = (not toggled) }

  in { header | cartdrawer = cartdrawer }


toggleCartGutter : HeaderC -> Catalog -> Catalog
toggleCartGutter header catalog =
  { catalog | cartToggled = header.cartdrawer.toggled }


toggleCartdrawerSubTotal : HeaderC -> HeaderC
toggleCartdrawerSubTotal header =
  let cartdrawer_ = header.cartdrawer
      entriesShown = cartdrawer_.entriesShown
      cartdrawer =
        { cartdrawer_ | entriesShown = (not entriesShown) }

  in { header | cartdrawer = cartdrawer }


floatToMoney : Float -> String
floatToMoney price = "$ " ++ Round.round 2 price


-- RENDERS

renderItemBrowser : App.Model -> Model -> Html Msg
renderItemBrowser app_ model =
  case model of
    ItemBrowser settings browserView ->
      let header = browserView.header
          catalog = browserView.catalog
      in
        div
          [ ViewStyle.appContainer ]
          [ renderHeader header.navbar header.navdrawer
          , UseCase.viewCart (cartView header.cartdrawer)
                             (App.store app_)
          , renderAddBanner
          , UseCase.browseCatalog (catalogView settings catalog)
                                  (App.store app_)
          , showPagination settings 20 1
          , renderFooter
          ]


showPagination : Settings -> Int -> Int -> Html Msg
showPagination settings pageCount currentPage =
  let spacing = settings.spacing
      theme = settings.theme
      font = settings.font
      wrapperStyle =
        css
          [ paddingLeft (px spacing.s1)
          , paddingRight (px spacing.s1)
          , marginTop (px spacing.s1)
          ]

      contentStyle =
        css
          [ displayFlex
          , maxWidth (px 500)
          , ViewStyle.elevation2Style
          , marginLeft auto
          , marginRight auto
          ]

      btnStyleClass =
        batch
          [ borderStyle none
          , outline none
          , backgroundColor (hex theme.background)
          , padding (px spacing.s1)
          , color (hex theme.onBackground)
          , height (px spacing.s4)
          ]

      prevStyle = css [ btnStyleClass ]

      nextStyle =
        css
          [ btnStyleClass
          , display inlineBlock
          , marginLeft auto
          ]

      ellipsisStyleClass =
        batch
          [ display inlineBlock
          , padding (px spacing.s1)
          , paddingBottom (px spacing.s1)
          , width (px spacing.s4)
          , height (px spacing.s4)
          , fontSize (px 20)
          , backgroundColor (hex theme.background)
          , boxSizing borderBox
          ]

      ellipsisStyle_prev =
        css
          [ ellipsisStyleClass
          , marginLeft auto
          , textAlign right
          ]

      ellipsisStyle_next =
        css
          [ ellipsisStyleClass
          , marginRight auto
          ]

      pagesWrapperStyle =
        css
          [ displayFlex
          , flexWrap wrap
          , height (px spacing.s4)
          , overflow hidden
          , backgroundColor (hex theme.background)
          ]

      pageStyleClass =
        batch
          [ btnStyleClass
          , fontSize (px 18)
          , height (pct 100)
          ]

      pageStyle =
        css
          [ pageStyleClass
          , hover
              [ backgroundColor (hex theme.primary)
              , opacity (num 0.4)
              , color (hex theme.onBackground)
              ]
          ]

      pageStyle_current =
        css
          [ pageStyleClass
          , backgroundColor (hsla 172 1 0.37 0.4)
          , color (hex theme.onPrimary)
          ]

  in div
       [ wrapperStyle ]
       [ div
           [ contentStyle ]
           [ button
               [ prevStyle ]
               [ i [ class "material-icons" ] [ text "arrow_back" ] ]
           , span [ ellipsisStyle_prev ] [ text "..." ]
           , div
               [ pagesWrapperStyle ]
               (List.map
                 (\i ->
                   button
                     [ if i == currentPage
                        then pageStyle_current
                        else pageStyle
                     ]
                     [ text (String.fromInt i) ]
                 ) (List.range 1 pageCount)
               )
           , span
               [ ellipsisStyle_next ] [ text "..." ]
           , button
               [ nextStyle ]
               [ i [ class "material-icons" ] [ text "arrow_forward" ] ]
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


cartView : CartC -> UseCase.CartView (Html Msg)
cartView cart
         saleSubTotal
         taxPct
         saleTax
         saleTotal
         totalSavings
         cartEntries
  = let toggled = cart.toggled
        entriesShown = cart.entriesShown
        theme = cart.theme
        spacing = cart.spacing

        topbarStyle =
          css
            [ displayFlex
            , alignItems center
            , textAlign right
            , backgroundColor (hex theme.background)
            , paddingLeft (px spacing.s1)
            , paddingRight (px spacing.s1)
            , boxSizing contentBox
            , height (px spacing.s6)
            , borderBottomStyle solid
            , borderWidth (px spacing.s1)
            , borderColor (hex theme.lighterGrey)
            ]

        titleStyle =
          css
            [ fontSize (px 18)
            , color (hex theme.onBackground)
            , textTransform capitalize
            , paddingTop (px spacing.s1)
            , paddingBottom (px spacing.s1)
            ]

        topbarBtnStyle =
          css
            [ borderStyle none
            , backgroundColor inherit
            , outlineStyle none
            , display inlineBlock
            , cursor pointer
            , textDecoration none
            , padding (px spacing.s1)
            , color (hex theme.onBackground)
            ]

        topbarIconsStyle = css [ fontSize (px 18) ]

        topbarRight = css [ marginLeft auto ]

        topbar =
          div
            [ topbarStyle ]
            [ div [ titleStyle ] [ text "shopping Cart" ]
            , div
                [ topbarRight ]
                [ button
                    [ topbarBtnStyle, onClick ViewCart ]
                    [ i [ class "material-icons", topbarIconsStyle ]
                        [ text "vertical_split" ]
                    ]
                , button
                    [ topbarBtnStyle, onClick ViewCart ]
                    [ i [ class "material-icons", topbarIconsStyle ]
                        [ text "close" ]
                    ]
                ]
            ]

        summaryLineStyle =
          css
            [ displayFlex
            , color (hex theme.onBackground)
            , lineHeight (px spacing.s2)
            , justifyContent spaceBetween
            , paddingBottom (px spacing.s1)
            ]

        labelStyle =
          css
            [ textAlign left
            , textTransform capitalize
            , fontWeight bold
            , fontSize (px 14)
            ]

        valueStyle =
          css
            [ textAlign right
            , fontSize (px 14)
            , fontWeight bold
            ]

        collapseBtnStyle =
          css
            [ borderStyle none
            , backgroundColor inherit
            , textTransform capitalize
            , outlineStyle none
            , cursor pointer
            , padding (px 0)
            , textDecoration none
            , fontSize (px 14)
            , fontWeight bold
            , displayFlex
            , alignItems center
            , color (hex theme.onBackground)
            ]

        collapseIconStyle =
          css
            [ fontSize (px spacing.s2)
            , display inlineBlock
            , marginLeft (px spacing.s1)
            ]

        entriesPanelStyle_Hidden =
          css
            [ width (pct 100)
            , overflow hidden
            , height (px 0)
            , Transitions.transition
                [ Transitions.height 4000 ]
            ]

        entriesPanelStyle_Shown =
          css
            [ width (pct 100)
            , paddingTop (px spacing.s2)
            ]

        subTotalLine =
          div
            [ summaryLineStyle ]
            [ span
                [ labelStyle ]
                [ button
                    [ collapseBtnStyle
                    , onClick ViewCartSubTotal
                    ]
                    [ text "sub-total"
                    , i [ class "material-icons", collapseIconStyle ]
                        [ text
                            (if entriesShown
                              then "expand_less"
                              else "expand_more")
                        ]
                    ]
                ]
            , span [ valueStyle ] [ text (floatToMoney saleSubTotal) ]
            ]

        entriesPanel =
          div
            [ if entriesShown
                then entriesPanelStyle_Shown
                else entriesPanelStyle_Hidden
            ]
            [ div []
                (List.map (showCartEntry theme spacing) cartEntries)
            ]

        taxLine =
          div
            [ summaryLineStyle ]
            [ span
                [ labelStyle ]
                [ text
                    ( "tax (" ++
                      (String.fromFloat taxPct) ++
                      "%)"
                    )
                ]
            , span [ valueStyle ] [ text (floatToMoney saleTax) ]
            ]

        totalLineStyle =
          css
            [ displayFlex
            , justifyContent spaceBetween
            , borderTopStyle solid
            , borderColor (hex theme.lighterGrey)
            , borderWidth (px 1)
            , paddingTop (px spacing.s3)
            , paddingBottom (px spacing.s3)
            , color (hex theme.onBackground)
            , lineHeight (px spacing.s2)
            ]

        totalLine =
          div
            [ totalLineStyle ]
            [ span
                [ labelStyle ]
                [ text "total" ]
            , span [ valueStyle ] [ text (floatToMoney saleTotal) ] ]

        savingsLine =
          div
            [ summaryLineStyle ]
            [ span
                [ labelStyle ]
                [ text "total savings" ]
            , span [ valueStyle ] [ text (floatToMoney totalSavings) ]
            ]

        ctaBlockStyle = css [ displayFlex, paddingTop (px spacing.s4) ]

        ctaBlock =
          div
            [ ctaBlockStyle ]
            [ button
                [ ViewStyle.btnFilledSecondary ]
                [ text "proceed to checkout" ]
            ]

        contentStyle =
          css
            [ width (pct 100)
            , overflowY auto
            , paddingTop (px spacing.s3)
            , paddingLeft (px spacing.s1)
            , paddingRight (px spacing.s1)
            , boxSizing borderBox
            ]

        content =
          div
            [ contentStyle ]
            [ subTotalLine
            , entriesPanel
            , taxLine
            , totalLine
            , savingsLine
            , ctaBlock
            ]

        cartStyle =
          css
            [ width (pct 100)
            , paddingTop (px 48)
            , boxSizing borderBox
            , backgroundColor (hex theme.background)
            , fontSize (px 14)
            , paddingBottom (px spacing.s4)
            ]

    in div [ cartStyle ] [ topbar, content ]


showCartEntry : Theme -> Spacing -> UseCase.EntryViewD -> Html Msg
showCartEntry theme spacing entry =
  let item = entry.item
      image = img [ src item.image, css [ width (px 80) ] ] []
      detailsBlockStyle =
        css
          [ paddingLeft (px spacing.s1)
          , flexGrow (num 0)
          , flexShrink (num 0)
          , flexBasis (pct 40)
          , lineHeight (px spacing.s2)
          ]

      variantStyle = 
        css
          [ color (hex theme.darkGrey)
          , textTransform capitalize
          ]

      qtyBlockStyle =
        css
         [ marginTop (px spacing.s1)
         , maxWidth (px 140)
         , displayFlex
         ]

      qtyBtnStyleClass =
        batch
          [ paddingLeft (px spacing.s1)
          , paddingRight (px spacing.s1)
          , flexGrow (num 2)
          , flexShrink (num 2)
          , flexBasis auto
          , lineHeight (px spacing.s2)
          , backgroundColor (hex theme.lighterGrey)
          , borderStyle none
          , outline none
          ]

      qtyBtnDecStyle =
        css
          [ qtyBtnStyleClass
          , borderTopLeftRadius (px 4)
          , borderBottomLeftRadius (px 4)
          ]

      qtyBtnIncStyle =
        css
          [ qtyBtnStyleClass
          , borderTopRightRadius (px 4)
          , borderBottomRightRadius (px 4)
          ]

      qtyValStyle =
        css
          [ display inlineBlock
          , flexGrow (num 3)
          , flexShrink (num 3)
          , flexBasis auto
          , textAlign center
          , backgroundColor (hex theme.background)
          ]

      sizeStyle = css [ textTransform capitalize ]

      entryNameStyle =
        css 
          [ textTransform capitalize
          , fontSize (px 14)
          , lineHeight (px spacing.s2)
          , fontWeight bold
          , height <| px (2 * spacing.s2)
          , overflow hidden
          ]

      entryName =
        div
          [ entryNameStyle ]
          [ let name = item.name ++ " by " ++ item.brand
                maybeFirstWord = List.head (String.words name)
            in
              case maybeFirstWord of
                Nothing -> text name
                Just firstWord ->
                  if String.length firstWord > 17
                    then
                      text <| (String.dropRight 3 firstWord) ++ " ..."
                  else if String.length name > 24
                    then text <| (String.dropRight 3 name) ++ " ..."
                    else text name
          ]

      detailsBlock =
        div
          [ detailsBlockStyle ]
          [ entryName
          , span
              [ variantStyle ] [ text (item.variant ++ ", ") ]
          , span
              [ sizeStyle ] [ text item.size ]
          , div
              [ qtyBlockStyle ]
              [ button
                  [ qtyBtnDecStyle
                  , onClick <| AppMsg (App.RemoveItemFromCart item.id)
                  ]
                  [ text "-" ]
              , span
                  [ qtyValStyle ] [ text (String.fromInt entry.qty) ]
              , button
                  [ qtyBtnIncStyle
                  , onClick <| AppMsg (App.AddItemToCart item.id)
                  ]
                  [ text "+" ]
              ]
          ]

      priceBlockStyle =
        css
          [ textAlign right
          , fontSize (px 14)
          , lineHeight (px spacing.s2)
          , paddingLeft (px spacing.s1)
          , marginLeft auto
          ]

      listPriceStyle = 
        css
          [ textDecoration lineThrough
          , color (hex theme.lightGrey)
          ]

      priceBlock =
        div
          [ priceBlockStyle ]
          <| [ div
                 [ if entry.saleTotal < entry.listTotal
                     then listPriceStyle
                     else css []
                 ]
                 [ text (floatToMoney entry.listTotal) ]
             ] ++ 
             if entry.saleTotal < entry.listTotal
               then [ div [] [ text (floatToMoney entry.saleTotal) ] ]
               else []

      entryStyle =
        css
          [ width (pct 100)
          , marginBottom (px spacing.s2)
          , paddingBottom (px spacing.s1)
          , borderBottomStyle solid
          , borderWidth (px 1)
          , borderColor (hex theme.lighterGrey)
          , displayFlex
          , lineHeight (px spacing.s2)
          , fontSize (px 13)
          , color (hex theme.onBackground)
          ]

  in div [ entryStyle ]
         [ image
         , detailsBlock
         , priceBlock
         ]


catalogView : Settings -> Catalog -> List UseCase.ItemViewD -> Html Msg
catalogView settings catalog data =
  let cartToggled = catalog.cartToggled
  in div
       [ ViewStyle.catalogContainer cartToggled ]
       (List.map (renderCatalogItem settings) data)


renderCatalogItem : Settings -> UseCase.ItemViewD -> Html Msg
renderCatalogItem settings item =
  let liftAnimationDuration  = 400
      itemMaxWidth           = 200
      nameMaxLines           = 3
      itemStyle =
        css
          [ backgroundColor (hex settings.theme.background)
          , padding (px settings.spacing.s1)
          , paddingBottom (px settings.spacing.s2)
          , lineHeight (px settings.spacing.s2)
          , hover [ ViewStyle.elevation6Style ]
          , Transitions.transition
              [ Transitions.boxShadow liftAnimationDuration ]
          ]

      wrapperStyle =
        css
          [ backgroundColor transparent
          , maxWidth (px itemMaxWidth)
          , width (pct 50)
          , boxSizing borderBox
          , paddingBottom (px settings.spacing.s1)
          , paddingRight (px (0.5 * settings.spacing.s1))
          , paddingLeft (px (0.5 * settings.spacing.s1))
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
          , color (hex settings.theme.onBackground)
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
          , color (hex settings.theme.onBackground)
          , paddingBottom (px settings.spacing.s1)
          , height <| px
              ((toFloat nameMaxLines) * settings.spacing.s2)
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
                   |> IconButton.setOnClick ViewCart
                   |> IconButton.setAttributes
                        [ TopAppBar.navigationIcon
                        ]
                  )
                  "shopping_cart")
            ]
        ]
    ]


