module Main exposing (..)

import Url
import Time
import Task
import Html exposing (Html)
import Html.Styled exposing (toUnstyled)
import Browser
import Browser.Navigation as Nav

import UseCase
import View
import App


-----------------------------------------------------------------------
-- CONSTANT DEFINITIONS
-----------------------------------------------------------------------

defaultTax = 12.4



-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

type alias Model =
  { app  : App.Model
  , view : View.Model
  }


type Msg
  = UrlChanged Url.Url
  | LinkClicked Browser.UrlRequest
  | ViewMsg View.Msg
  | AppMsg App.Msg



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
  let app = App.newItemBrowser defaultTax
  in
    ( { app  = app , view = View.app app }
    , liftCmd (Cmd.batch [App.loadData app, App.loadCart app])
    )


view : Model -> Browser.Document Msg
view model =
  let content =
        if (App.isItemBrowser model.app)
          then
            toUnstyled <| View.renderItemBrowser model.app model.view
          else
            toUnstyled <| View.renderItemBrowser model.app model.view

  in { title = "test" , body = [ liftHtml content ] }


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UrlChanged url -> (model, Cmd.none)

    LinkClicked urlRequest -> (model, Cmd.none)

    ViewMsg viewMsg ->
      if View.isAppMsg viewMsg
        then
          case View.unwrapAppMsg viewMsg of
            Nothing -> ( model, Cmd.none )
            Just appMsg ->
              ( { model
                | app = App.update appMsg model.app
                }
              , Cmd.none
              )
        else
          ( { model | view = View.update viewMsg model.view }
          , Cmd.none
          )

    AppMsg appMsg ->
      ( { model | app = App.update appMsg model.app }
      , Cmd.none
      )


liftHtml : Html View.Msg -> Html Msg
liftHtml = Html.map (\viewMsg -> ViewMsg viewMsg)


liftCmd : Cmd App.Msg -> Cmd Msg
liftCmd = Cmd.map (\appMsg -> AppMsg appMsg)


