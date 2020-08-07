module Main exposing (..)

import Url
import Html exposing (Html)
import Browser
import Browser.Navigation as Nav

import App
import View


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
  | AppMsg App.Msg
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
  ( { app  = App.Loading
    , view = View.Loading
    }
  , Cmd.none
  )


view : Model -> Browser.Document Msg
view model =
  { title = App.getTitle model.app
  , body =
      [ liftHtml <| View.renderApp model.view model.app
      ]
  }


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UrlChanged url -> (model, Cmd.none)

    LinkClicked urlRequest -> (model, Cmd.none)

    AppMsg appMsg ->
      ( { model | app =  App.update appMsg model.app }
      , Cmd.none
      )

    ViewMsg viewMsg ->
      ( { model | view = View.update viewMsg model.view }
      , Cmd.none
      )


liftHtml : Html View.Msg -> Html Msg
liftHtml =
  Html.map (\viewMsg -> ViewMsg viewMsg)


