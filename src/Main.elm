module Main exposing (..)

import Url
import Time
import Task
import Html exposing (Html)
import Html.Styled exposing (toUnstyled)
import Browser
import Browser.Navigation as Nav

import Item
import ShoppingList
import UseCase
import View

-- TEST PURPOSES ONLY
import DummyItem
import DummyShoppingList


-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

type alias Model =
  { app  : App
  , view : View.Model
  }


type App
  = Loading ShoppingList.Model
  | ItemBrowser ShoppingList.Model Item.Set


type Msg
  = UrlChanged Url.Url
  | LinkClicked Browser.UrlRequest
  | ViewMsg View.Msg
  | GotDummyData Int



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
    , loadDummyData
    )


view : Model -> Browser.Document Msg
view model =
  let
    content =
      case model.app of
        Loading cart -> Html.div [] []

        ItemBrowser cart items ->
          toUnstyled <| View.renderItemBrowser cart items model.view
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

    GotDummyData seed ->
      ( { model
        | app = ItemBrowser (DummyShoppingList.randomList seed)
                            (DummyItem.randomSet seed)
        }
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
              False
              [ { label = "test1"
                , value = "test"
                , active = False
                }
              ]
        , navbar = View.NavbarC
        , cartdrawer = View.CartdrawerC False ShoppingList.empty
        }
  in
    case app of
      Loading cart ->
        View.Loading { header = header }

      ItemBrowser cart items ->
        View.ItemBrowser 
          { header = header }


loadDummyData : Cmd Msg
loadDummyData =
  Task.perform
    (\pTime ->
      GotDummyData (Time.posixToMillis pTime)
    ) Time.now
