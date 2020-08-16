module ViewStyle exposing (..)

import Css exposing (..)
import Css.Transitions as Transitions
import Css.Media as Media
import Html.Styled exposing (Attribute)
import Html.Styled.Attributes exposing (css)


drawerMaxWidth = 320 -- px
drawerMdMaxWidth = 49 -- vw
drawerContentWidth = 280 -- px
drawerAnimationDuration = 1 -- ms
drawerContentAnimationDuration = 300 -- ms
baseline = 16 -- px
defaultFontSize = 13 -- px
navbarHeight = 48 -- px
catalogItemWidth = 200  --px


navbarZIndex = 10
navdrawerZIndex = 12
cartdrawerZIndex = 8


type alias Breakpoint =
  { sm  : Float  -- px
  , md  : Float  -- px
  , lg  : Float  -- px
  , xl  : Float  -- px
  }


type alias Space =
  { s1     : Px
  , sHalf  : Px
  , s2     : Px
  , s3     : Px
  }


type alias Theme =
  { primary         : Color
  , primary_light   : Color
  , primary_dark    : Color
  , secondary       : Color
  , secondary_light : Color
  , secondary_dark  : Color
  , danger          : Color
  , danger_light    : Color
  , on_danger_light : Color
  , danger_dark     : Color
  , on_danger_dark  : Color
  , background      : Color
  , content_bg      : Color
  , on_primary      : Color
  , on_secondary    : Color
  , on_surface      : Color
  , dark_grey       : Color
  , light_grey      : Color
  , lighter_grey    : Color
  , light_green     : Color
  }


breakpoint : Breakpoint
breakpoint =
  { sm  = 600
  , md  = 960
  , lg  = 1280
  , xl  = 1920
  }


theme : Theme
theme =
  { primary         = hex "1a237e"
  , primary_light   = hex "534bae"
  , primary_dark    = hex "000051"
  , secondary       = hex "00bfa5"
  , secondary_light = hex "5df2d6"
  , secondary_dark  = hex "008e76"
  , danger          = hex "d50000"
  , danger_light    = hex "ff5131"
  , on_danger_light = hex "000"
  , danger_dark     = hex "9b0000"
  , on_danger_dark  = hex "fff"
  , background      = hex "fff"
  , content_bg      = hex "eaeded"
  , on_primary      = hex "fff"
  , on_secondary    = hex "000"
  , on_surface      = hex "041e42"
  , light_grey      = hex "77859940"
  , dark_grey       = hex "738195"
  , lighter_grey    = hex "f5f6f7"
  , light_green     = hex "#76ff03"
  }


space : Space
space =
  { s1     = (px baseline)
  , sHalf  = (px <| baseline/2)
  , s2     = (px <| baseline*2)
  , s3     = (px <| baseline*3)
  }


navdrawerHidden : Attribute msg
navdrawerHidden =
  let delay = drawerContentAnimationDuration
  in
    css
      [ navdrawerStyle
      , transform (translateX (pct -100))
      , Transitions.transition
          [ Transitions.transform2
              drawerAnimationDuration
              delay ]
      ]


navdrawerShown : Attribute msg
navdrawerShown =
  css
    [ navdrawerStyle
    , transform (translateX (pct 0))
    , Transitions.transition
        [Transitions.transform drawerAnimationDuration]
    ]


navdrawerStyle : Style
navdrawerStyle =
  batch
    [ width (pct 100)
    , height (vh 100)
    , position fixed
    , top (px 0)
    , left (px 0)
    , zIndex (int navdrawerZIndex)
    , color theme.primary
    ]


navdrawerHiddenScrim : Attribute msg
navdrawerHiddenScrim =
  let delay = drawerAnimationDuration
  in
    css
      [ navdrawerScrimStyle
      , opacity (num 0)
      , Transitions.transition
          [ Transitions.opacity2
              drawerContentAnimationDuration
              delay
              ]
      ]


navdrawerShownScrim : Attribute msg
navdrawerShownScrim =
  let delay = drawerAnimationDuration
  in
    css
      [ navdrawerScrimStyle
      , opacity (num 0.4)
        , Transitions.transition
            [ Transitions.opacity2
                drawerContentAnimationDuration
                delay
                ]
      ]


navdrawerScrimStyle : Style
navdrawerScrimStyle =
  batch
    [ width (pct 100)
    , height (pct 100)
    , backgroundColor (hex "000")
    , position relative
    ]


navdrawerHiddenContent : Attribute msg
navdrawerHiddenContent =
  let delay = drawerAnimationDuration
  in
    css
      [ navdrawerContentStyle
      , transform (translateX <| px (negate drawerContentWidth))
        , Transitions.transition
            [ Transitions.transform2
                drawerContentAnimationDuration
                delay
                ]
      ]


navdrawerShownContent : Attribute msg
navdrawerShownContent =
  let delay = drawerAnimationDuration
  in
    css
      [ navdrawerContentStyle
      , transform (translateX (px 0))
        , Transitions.transition
            [ Transitions.transform2
                drawerContentAnimationDuration
                delay
                ]
      ]


navdrawerContentStyle : Style
navdrawerContentStyle =
  batch
    [ width (pct 80)
    , maxWidth (px drawerContentWidth)
    , height (pct 100)
    , overflow auto
    , backgroundColor theme.background
    , position absolute
    , top (px 0)
    , left (px 0)
    , displayFlex
    , flexDirection column
    , pl1Style
    , pr1Style
    ]


navdrawerNav : Attribute msg
navdrawerNav =
  css
    [ fontSize (px defaultFontSize)
    , borderBottomStyle solid
    , borderColor theme.lighter_grey
    , borderWidth (px 1)
    , paddingBottom (px 12)
    ]


navItem : Attribute msg
navItem =
  css [ navItemStyle ]


navItemActive : Attribute msg
navItemActive =
  css
    [ navItemStyle
    , backgroundColor theme.lighter_grey
    ]


navItemStyle : Style
navItemStyle =
  batch
    [ width (pct 100)
    , paddingBottom (px 12)
    , textTransform uppercase
    ]


navbar : Attribute msg
navbar =
  css
    [ backgroundColor theme.background
    , position fixed
    , zIndex (int navbarZIndex)
    , height (px navbarHeight)
    , width (pct 100)
    , elevation3Style
    ]




logo : Attribute msg
logo =
  css
    [ padding (px 12) ]


searchBarContainer : Attribute msg
searchBarContainer =
  css
    [ width (pct 100)
    , pb1Style
    , displayFlex
    ]


searchBar : Attribute msg
searchBar =
  css
    [ width (pct 100)
    , pHalfStyle
    , fontSize (px defaultFontSize)
    , borderStyle solid
    , borderWidth (px 1)
    , borderColor  theme.lighter_grey
    , outline none
    ]


navbarCartToggle : Attribute msg
navbarCartToggle =
  css
    [ marginLeft auto ]


drawerTopBar : Attribute msg
drawerTopBar =
  css
    [ displayFlex
    , textAlign right
    -- , color theme.light_grey
    , backgroundColor theme.secondary
    , paddingLeft (px 12)
    , paddingRight (px 12)
    , boxSizing borderBox
    ]




drawerTopBarTitle : Attribute msg
drawerTopBarTitle =
  css
    [ fontSize (px 18)
    , color theme.on_primary
    , textTransform capitalize
    , paddingTop (px 12)
    , paddingBottom (px 12)
    ]


addBanner : Attribute msg
addBanner =
  css
    [ backgroundImage
        <| linearGradient (stop theme.background)
                          (stop (hsla 0 0 0 0))  []
    , height (px 125)
    , marginTop (px 48)
    ]


btnClose : Attribute msg
btnClose =
  css
    [ btnCloseStyle ]


btnCloseCart : Attribute msg
btnCloseCart =
  css
    [ btnCloseStyle
    , color theme.on_primary
    ]


btnCloseStyle : Style
btnCloseStyle =
  batch
    [ btnSimpleStyle
    , display inlineBlock
    , marginLeft auto
    , pl1Style
    , pt1Style
    , pb1Style
    ]


btnSearch : Attribute msg
btnSearch =
  css
    [ btnSimpleStyle
    , pHalfStyle
    , borderStyle solid
    , borderWidth (px 1)
    , borderColor theme.lighter_grey
    , borderLeftStyle none
    ]


btnSimpleStyle : Style
btnSimpleStyle =
  batch
    [ borderStyle none
    , backgroundColor inherit
    , outlineStyle none
    , fontSize (px defaultFontSize)
    , fontWeight normal
    , color theme.primary
    , padding (px 0)
    , cursor pointer
    , textTransform capitalize
    , textDecoration none
    ]


btnDanger : Attribute msg
btnDanger =
  css [ btnDangerStyle ]


btnDangerCartdrawer : Attribute msg
btnDangerCartdrawer =
  css
    [ btnDangerStyle
    , ml2Style
    ]


btnDangerStyle : Style
btnDangerStyle =
  batch
    [ btnStyle
    , btnMediumStyle
    , btnOutlineStyle
    , color theme.danger
    , borderColor theme.danger
    ]


btnFilledPrimaryBlock : Attribute msg
btnFilledPrimaryBlock =
  css [ btnFilledPrimaryBlockStyle ]


btnFilter : Attribute msg
btnFilter =
  css
    [ btnFilledPrimaryBlockStyle
    , Media.withMedia
        [ Media.only Media.screen [ Media.minWidth (px 620) ] ]
        [ maxWidth (px drawerContentWidth)
        , fontSize (px 12)
        ]
    ]


btnFilledPrimaryBlockStyle : Style
btnFilledPrimaryBlockStyle =
  batch
    [ btnPrimaryStyle
    , btnFilledPrimaryStyle
    , width (pct 100)
    , fontWeight bold
    ]


btnPrimaryBlock : Attribute msg
btnPrimaryBlock =
  css
    [ btnPrimaryStyle
    , width (pct 100)
    ]


btnFilledPrimary : Attribute msg
btnFilledPrimary =
  css
    [ btnFilledPrimaryStyle
    , btnMediumStyle
    , btnStyle
    , borderStyle none
    , fontWeight bold
    ]


btnFilledSecondary : Attribute msg
btnFilledSecondary =
  css
    [ btnFilledSecondaryStyle
    , btnMediumStyle
    , btnStyle
    , borderStyle none
    ]




btnFilledPrimaryStyle : Style
btnFilledPrimaryStyle =
  batch
    [ backgroundColor theme.primary
    , color theme.on_primary
    ]


btnFilledSecondaryStyle : Style
btnFilledSecondaryStyle =
  batch
    [ backgroundColor theme.secondary
    , color theme.on_primary
    ]


btnPrimary : Attribute msg
btnPrimary =
  css [ btnPrimaryStyle ]


btnSecondary : Attribute msg
btnSecondary =
  css [ btnSecondaryStyle ]


btnPrimaryStyle : Style
btnPrimaryStyle =
  batch
    [ btnStyle
    , btnOutlineStyle
    , borderColor theme.primary
    , color theme.primary
    , btnMediumStyle
    ]


btnSecondaryStyle : Style
btnSecondaryStyle =
  batch
    [ btnStyle
    , btnOutlineStyle
    , borderColor theme.secondary
    , color theme.on_secondary
    , btnMediumStyle
    ]


btnMediumStyle : Style
btnMediumStyle =
  batch
    [ fontSize (px defaultFontSize)
    , padding (px 10)
    ]


btnOutlineBlock : Attribute msg
btnOutlineBlock =
  css
    [ btnOutlineBlockStyle
    ]


btnOutlineBlockStyle : Style
btnOutlineBlockStyle =
  batch
    [ btnStyle
    , btnOutlineStyle
    , btnMediumStyle
    , width (pct 100)
    ]


btnOutlineStyle : Style
btnOutlineStyle =
  batch
    [ borderStyle solid
    , borderWidth (px 1)
    , backgroundColor theme.background
    ]


btnStyle =
  batch
    [ outline none
    , fontWeight bold
    , textTransform uppercase
    , textDecoration none
    , cursor pointer
    , borderRadius (px 4)
    ]


entryNameLineH = 18


footer : Attribute msg
footer =
  css
    [ -- marginTop (px 24)
    paddingTop (px 16)
    , paddingBottom (px 8)
    , height (px 50)
    , borderTopStyle solid
    , borderWidth (px 12)
    , borderColor theme.secondary
    , backgroundColor theme.secondary_dark
    , Media.withMedia
        [ Media.only Media.screen [ Media.minWidth (px 720) ] ]
        [ -- marginTop (px 62)
        ]
    ]


filterPanel : Attribute msg
filterPanel =
  css
    [ borderRightStyle solid
    , borderWidth (px 1)
    , borderColor theme.lighter_grey
    , Media.withMedia
        [ Media.only Media.screen [ Media.minWidth (px 620) ] ]
        [ height (pct 100) ]
    ]


filterBar : Attribute msg
filterBar =
  css
    [ width (pct 100)
    , borderBottomStyle solid
    , borderBottomColor theme.lighter_grey
    , borderBottomWidth (px 1)
    , boxSizing borderBox
    , p1Style
    , displayFlex
    , flexWrap wrap
    ]


filterPanelSortBlock : Attribute msg
filterPanelSortBlock =
  css
    []


filterBtnContainer : Attribute msg
filterBtnContainer =
  css
    [ width (pct 50)
    , displayFlex
    , justifyContent flexEnd
    , boxSizing borderBox
    , plHalfStyle
    ]


filterBarSearchContainer : Attribute msg
filterBarSearchContainer =
  css
    [ width (pct 100)
    , displayFlex
    , boxSizing borderBox
    ]


filterResetBtnContainer : Attribute msg
filterResetBtnContainer =
  css
    [ width (pct 50)
    , displayFlex
    , boxSizing borderBox
    , prHalfStyle
    ]


pageContainer : Attribute msg
pageContainer =
  css
    [ paddingTop (px navbarHeight)
    , minHeight (pct 100)
    , Media.withMedia
        [ Media.only Media.screen [ Media.minWidth (px 620) ] ]
        [ displayFlex ]
    ]


pageLeftPanel : Attribute msg
pageLeftPanel =
  css
    [ boxSizing borderBox
    -- , position absolute
    , pt1Style
    , Media.withMedia
        [ Media.only Media.screen [ Media.minWidth (px 620) ] ]
        [ maxWidth (px drawerContentWidth)
        , height unset
        , flexGrow (num 0)
        , flexShrink (num 0)
        , flexBasis auto
        , position static
        ]
      ]


pageMainPanel : Attribute msg
pageMainPanel =
  css
    [ width (pct 100)
    , boxSizing borderBox
    , pt2Style
    , Media.withMedia
        [ Media.only Media.screen [ Media.minWidth (px 620) ] ]
        [ pl1Style ]
    ]


slider : Attribute msg
slider =
  css
    [ width (pct 100)
    , overflow hidden
    , position relative
    , height (px 300)
    , boxSizing borderBox
    ]


sliderCtrlRight : Attribute msg
sliderCtrlRight =
  css
    [ sliderCtrlStyle
    , right space.sHalf
    ]


sliderCtrlLeft : Attribute msg
sliderCtrlLeft =
  css
    [ sliderCtrlStyle
    , left space.sHalf
    ]


sliderCtrlStyle : Style
sliderCtrlStyle =
  batch
    [ position absolute
    , displayFlex
    , alignItems center
    , top (pct 35)
    , backgroundColor theme.primary
    , color theme.on_primary
    , borderStyle none
    , zIndex (int 1)
    , pHalfStyle
    , borderRadius (pct 50)
    -- , height (pct 100)
    ]


sliderWindow : Attribute msg
sliderWindow =
  css
    [ property "scroll-behavior" "smooth"
    , overflowY hidden
    , overflowX scroll
    , boxSizing borderBox
    , position relative
    , height (px 320)
    ]


slide : Attribute msg
slide =
  css
    [ displayFlex
    , flexWrap noWrap
    , pr1Style
    , position absolute
    , height (pct 100)
    ]


sliderWrapper : Attribute msg
sliderWrapper =
  css
    [ borderBottomStyle solid
    , borderWidth (px 1)
    , borderColor theme.light_grey
    , mb1Style
    , pb1Style
    ]


sliderHeader : Attribute msg
sliderHeader =
  css
    [ h2Style
    , px1Style
    , mb2Style
    ]


seeMoreWrapper : Attribute msg
seeMoreWrapper =
  css
    [ displayFlex
    , justifyContent center
    , pt1Style
    , pbHalfStyle
    ]


sliderItem : Attribute msg
sliderItem =
  css
    [ display block
    , flexGrow (num 0)
    , flexShrink (num 0)
    , flexBasis auto
    , width (px 160)
    , boxSizing borderBox
    , px1Style
    , pyHalfStyle
    , simpleLinkStyle
    , height (pct 100)
    ]


sliderItemThumbnail : String -> Attribute msg
sliderItemThumbnail imgUrl =
  css
    [ width (pct 100)
    , paddingTop (pct 100)
    , backgroundImage (url imgUrl)
    , backgroundPosition center
    , backgroundSize cover
    ]


sliderItemBody : Attribute msg
sliderItemBody =
  css
    [ displayFlex
    , justifyContent center
    , ptHalfStyle
    , pb2Style
    ]


sliderItemDesc : Attribute msg
sliderItemDesc =
  css
    [ textTransform capitalize
    , textAlign center
    , textDecoration none
    , lineHeight (num 1.5)
    , color theme.primary
    ]


h2Style : Style
h2Style =
  batch
    [ fontSize (px 18)
    , textTransform capitalize
    , color theme.primary
    ]


mlAutoStyle : Style
mlAutoStyle = marginLeft auto


mlHalfStyle : Style
mlHalfStyle = marginLeft space.sHalf


ml1Style : Style
ml1Style = marginLeft space.s1


ml2Style : Style
ml2Style = marginLeft space.s2


mt1Style : Style
mt1Style = marginTop space.s1


mb1Style : Style
mb1Style = marginBottom space.s1


mb2Style : Style
mb2Style = marginBottom space.s2


px1Style : Style
px1Style =
  batch
    [ pl1Style
    , pr1Style
    ]


px2Style : Style
px2Style =
  batch
    [ pl2Style
    , pr2Style
    ]


py2Style : Style
py2Style =
  batch
    [ pt2Style
    , pb2Style
    ]


p1Style : Style
p1Style = padding space.s1

pb1Style : Style
pb1Style = paddingBottom space.s1


pt1Style : Style
pt1Style = paddingTop space.s1


pl1Style : Style
pl1Style = paddingLeft space.s1


pr1Style : Style
pr1Style = paddingRight space.s1


pr2Style : Style
pr2Style = paddingRight space.s2


p2Style : Style
p2Style =
  batch
    [ px2Style
    , py2Style
    ]


pl2Style : Style
pl2Style = paddingLeft space.s2


pb2Style : Style
pb2Style = paddingBottom space.s2


pt2Style : Style
pt2Style = paddingTop space.s2


pt3Style : Style
pt3Style = paddingTop space.s3


pxHalfStyle : Style
pxHalfStyle = 
  batch
    [ plHalfStyle
    , prHalfStyle
    ]


pyHalfStyle : Style
pyHalfStyle = 
  batch
    [ ptHalfStyle
    , pbHalfStyle
    ]


pHalfStyle : Style
pHalfStyle = padding space.sHalf


plHalfStyle : Style
plHalfStyle = paddingLeft space.sHalf


ptHalfStyle : Style
ptHalfStyle = paddingTop space.sHalf


pbHalfStyle : Style
pbHalfStyle = paddingBottom space.sHalf


prHalfStyle : Style
prHalfStyle = paddingRight space.sHalf

simpleLinkStyle : Style
simpleLinkStyle =
  batch
    [ textDecoration none
    ]


elevation1Stye : Style
elevation1Stye =
  property
    "box-shadow"
      <| "0px 2px 1px -1px rgba(0, 0, 0, 0.2)," ++
          "0px 1px 1px 0px rgba(0, 0, 0, 0.14)," ++
          "0px 1px 3px 0px rgba(0,0,0,.12);" 

elevation2Style : Style
elevation2Style =
  property
    "box-shadow"
      <| "0px 3px 1px -2px rgba(0, 0, 0, 0.2)," ++
         "0px 2px 2px 0px rgba(0, 0, 0, 0.14)," ++
         "0px 1px 5px 0px rgba(0,0,0,.12);"


elevation3Style : Style
elevation3Style =
  property
    "box-shadow"
      <| "0px 3px 3px -2px rgba(0, 0, 0, 0.2)," ++
         "0px 3px 4px 0px rgba(0, 0, 0, 0.14)," ++
         "0px 1px 8px 0px rgba(0,0,0,.12);"


elevation4Style : Style
elevation4Style =
  property
    "box-shadow"
      <| "0px 2px 4px -1px rgba(0, 0, 0, 0.2)," ++
         "0px 4px 5px 0px rgba(0, 0, 0, 0.14)," ++
         "0px 1px 10px 0px rgba(0,0,0,.12);"


elevation5Style : Style
elevation5Style =
  property
    "box-shadow"
      <| "0px 3px 5px -1px rgba(0, 0, 0, 0.2)," ++
         "0px 6px 10px 0px rgba(0, 0, 0, 0.14)," ++
         "0px 1px 18px 0px rgba(0,0,0,.12);"


elevation6Style : Style
elevation6Style =
  property
    "box-shadow" 
      <| "0px 3px 5px -1px rgba(0, 0, 0, 0.2)," ++
         "0px 6px 10px 0px rgba(0, 0, 0, 0.14)," ++
         "0px 1px 18px 0px rgba(0,0,0,.12);"

elevation7Style : Style
elevation7Style =
  property
    "box-shadow" 
      <| "0px 4px 5px -2px rgba(0, 0, 0, 0.2)," ++
         "0px 7px 10px 1px rgba(0, 0, 0, 0.14)," ++
         "0px 2px 16px 1px rgba(0,0,0,.12);"


elevation8Style : Style
elevation8Style =
  property
    "box-shadow" 
      <| "0px 5px 5px -3px rgba(0, 0, 0, 0.2)," ++
         "0px 8px 10px 1px rgba(0, 0, 0, 0.14)," ++
         "0px 3px 14px 2px rgba(0,0,0,.12);"


elevation9Style : Style
elevation9Style =
  property
    "box-shadow" 
      <| "0px 5px 6px -3px rgba(0, 0, 0, 0.2)," ++
         "0px 9px 12px 1px rgba(0, 0, 0, 0.14)," ++
         "0px 3px 16px 2px rgba(0,0,0,.12);"


elevation10Style : Style
elevation10Style  =
  property
    "box-shadow" 
      <| "0px 6px 6px -3px rgba(0, 0, 0, 0.2)," ++
         "0px 10px 14px 1px rgba(0, 0, 0, 0.14)," ++
         "0px 4px 18px 3px rgba(0,0,0,.12);"


elevation11Style : Style
elevation11Style =
  property
    "box-shadow" 
      <| "0px 6px 7px -4px rgba(0, 0, 0, 0.2)," ++
         "0px 11px 15px 1px rgba(0, 0, 0, 0.14)," ++
         "0px 4px 20px 3px rgba(0,0,0,.12);"

