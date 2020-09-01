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



main : Program () Model (Message.Model Model)
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = (\_ -> Sub.none)
    , onUrlChange = dispatch_url_changed_message
    , onUrlRequest = dispatch_link_clicked_message
    }


defaultTax : Store.GST
defaultTax = 12.4



init : () -> Url.Url -> Nav.Key -> (Model, Cmd (Message.Model Model))
init  _ url key =
  let currentRoute = Route.parse_route_from url
      startingStory = Story.create_blank_story
                        |> Story.use_gst defaultTax

  in  ( { story  = startingStory
        , view   = View.loadingView
        , route  = currentRoute
        , navKey = key
        }
      , Cmd.none
      )



view : Model -> Browser.Document (Message.Model Model)
view model =
  { title = "test" , body = [ Html.div [] [] ] }
  -- { title = "test" , body = View.viewBody model.view model.story }



update
  :  Message.Model Model
  -> Model
  -> (Model, Cmd (Message.Model Model))
update updateMessage model =
  Message.handle updateMessage model



dispatch_url_changed_message : Url.Url -> Message.Model Model
dispatch_url_changed_message url =
  let urlChangedArgs = Message.wrap_url_changed_arguments url
  in Message.new handle_url_change urlChangedArgs



dispatch_link_clicked_message : Browser.UrlRequest -> Message.Model Model
dispatch_link_clicked_message urlRequest =
  let linkClickedArgs = Message.wrap_link_clicked_arguments urlRequest
  in Message.new handle_link_click linkClickedArgs



handle_url_change : Message.Handler Model
handle_url_change arguments model =
  let possibleUrl = Message.unwrap_url_changed_arguments arguments
  in case possibleUrl of
       Nothing -> 
         ( Message.debug_log_message_argument_mismatch model
         , Cmd.none
         )

       Just url ->
         let newRoute = Route.parse_route_from url
         in ( model |> set_route_to newRoute , Cmd.none )



handle_link_click : Message.Handler Model
handle_link_click arguments model =
  let possibleUrlRequest =
        Message.unwrap_link_clicked_arguments arguments
  in case possibleUrlRequest of
       Nothing -> 
         ( Message.debug_log_message_argument_mismatch model
         , Cmd.none
         )

       Just urlRequest ->
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
