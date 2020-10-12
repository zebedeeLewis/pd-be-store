module Main exposing (..)

import Url
import Html exposing (Html)
import Browser
import Browser.Navigation as Nav

import Message
import Story
import Store
import View
import Route



type alias Model =
  { story  : Story.Model
  , view   : View.Model
  , route  : Route.Model
  , navKey : Nav.Key
  }



main : Program () Model (Message.Msg Model)
main =
  Browser.application
    { init = init
    , view = view
    , update = Message.update_rootModel
    , subscriptions = (\_ -> Sub.none)
    , onUrlChange = dispatch_message__urlChanged
    , onUrlRequest = dispatch_message__linkClicked
    }


defaultTax : Store.GST
defaultTax = 12.4



init : () -> Url.Url -> Nav.Key -> (Model, Cmd (Message.Msg Model))
init  _ url key =
  let currentRoute = Route.parse_route_from url
      startingStory = Story.create_blank_story
                        |> Story.use_gst defaultTax

  in  ( { story  = startingStory
        , view   = View.initView
        , route  = currentRoute
        , navKey = key
        }
      , Cmd.none
      )



view : Model -> Browser.Document (Message.Msg Model)
view model =
  { title = "test" , body = [ Html.div [] [] ] }
  -- { title = "test" , body = View.viewBody model.view model.story }



dispatch_message__linkClicked : Browser.UrlRequest -> Message.Msg Model
dispatch_message__linkClicked urlRequest =
  Message.dispatch_message__linkClicked handle_link_click urlRequest



dispatch_message__urlChanged : Url.Url -> Message.Msg Model
dispatch_message__urlChanged url =
  Message.dispatch_message__urlChanged handle_url_change url



handle_url_change : Message.UrlChangedHandler Model
handle_url_change url model =
  let newRoute = Route.parse_route_from url
  in ( model |> set_route_to newRoute , Cmd.none )



handle_link_click : Message.LinkClickedHandler Model
handle_link_click urlRequest model =
  case urlRequest of
    Browser.External url -> ( model, Nav.load url )
  
    Browser.Internal url ->
      let newRoute = Route.parse_route_from url
      in  ( model |> set_route_to newRoute
          , Nav.pushUrl model.navKey (Url.toString url)
          )



set_route_to : Route.Model -> Model -> Model
set_route_to newRoute model =
  Model model.story model.view newRoute model.navKey



set_view_to : View.Model -> Model -> Model
set_view_to newView model =
  Model model.story newView model.route model.navKey



set_story_to : Story.Model -> Model -> Model
set_story_to newStory model =
  Model newStory model.view model.route model.navKey
