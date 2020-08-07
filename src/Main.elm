module Main exposing (..)

import Url
import Html exposing (Html)
import Html.Styled exposing (toUnstyled)
import Browser
import Browser.Navigation as Nav

import Item
import ShoppingList
import UseCase
import View


-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

type alias Model =
  { app  : App
  , view : View.Model
  }


type App
  = Loading
  | ItemBrowser ShoppingList.ShoppingList Item.Set


type Msg
  = UrlChanged Url.Url
  | LinkClicked Browser.UrlRequest
  | ViewMsg View.Msg



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------
    
main : Program () Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = (\_ -> Sub.none)
    , onUrlChange = UrlChanged
    , onUrlRequest = LinkClicked
    }


init : () -> Url.Url -> Nav.Key -> (Model, Cmd Msg)
init  _ url key =
  let app = ItemBrowser ShoppingList.empty Item.emptySet
  in
    ( { app  = app
      , view = appView app
      }
    , Cmd.none
    )


view : Model -> Browser.Document Msg
view model =
  let
    content =
      case model.app of
        Loading -> Html.div [] []

        ItemBrowser cart items ->
          UseCase.viewItemSet
            (toUnstyled << View.renderItemBrowser model.view) items
  in
    { title = "test" , body = [ liftHtml content ] }


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UrlChanged url -> (model, Cmd.none)

    LinkClicked urlRequest -> (model, Cmd.none)

    ViewMsg viewMsg ->
      ( { model | view = View.update viewMsg model.view }
      , Cmd.none
      )


liftHtml : Html View.Msg -> Html Msg
liftHtml = Html.map (\viewMsg -> ViewMsg viewMsg)


{-| produce a view for the given app
-}
appView : App -> View.Model
appView app = 
  let header =
        { navdrawer =
            View.NavdrawerC
              True
              [ { label = "test1"
                , value = "test"
                , active = True
                }
              ]
        , navbar = View.NavbarC
        , cartdrawer = View.CartdrawerC True ShoppingList.empty
        }
  in
    case app of
      Loading ->
        View.Loading { header = header }

      ItemBrowser cart items ->
        View.ItemBrowser 
          { header = header }
