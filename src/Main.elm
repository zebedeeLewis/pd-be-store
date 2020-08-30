module Main exposing (..)

import Url
import Html exposing (Html)
import Browser
import Browser.Navigation as Nav

import Command
import Story
import View
import Route



type alias Model =
  { story  : Story.Model
  , view   : View.Model
  , route  : Route.Model
  , navKey : Nav.Key
  }



main : Program () Model (Command.Msg Model)
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = (\_ -> Sub.none)
    , onUrlChange = url_change_command
    , onUrlRequest = link_clicked_command
    }



defaultTax = 12.4



init : () -> Url.Url -> Nav.Key -> (Model, Cmd (Command.Msg Model))
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



view : Model -> Browser.Document (Command.Msg Model)
view model =
  { title = "test" , body = [ Html.div [] [] ] }
  -- { title = "test" , body = View.viewBody model.view model.story }



update : Command.Msg Model -> Model -> (Model, Cmd (Command.Msg Model))
update command model =
  Command.execute command model



url_change_command : Url.Url -> Command.Msg Model
url_change_command url =
  let urlChangedArgs = Command.wrap_url_changed_arguments url
  in Command.new handle_url_change urlChangedArgs



link_clicked_command : Browser.UrlRequest -> Command.Msg Model
link_clicked_command urlRequest =
  let linkClickedArgs = Command.wrap_link_clicked_arguments urlRequest
  in Command.new handle_link_click linkClickedArgs



handle_url_change : Command.Action Model
handle_url_change args model =
  let possibleUrl = Command.unwrap_url_changed_arguments args
  in case possibleUrl of
       Nothing -> 
         ( Command.debug_log_command_argument_mismatch model
         , Cmd.none
         )

       Just url ->
         let newRoute = Route.parse_route_from url
         in ( model |> set_route_to newRoute , Cmd.none )



handle_link_click : Command.Action Model
handle_link_click args model =
  let possibleUrlRequest = Command.unwrap_link_clicked_arguments args
  in case possibleUrlRequest of
       Nothing -> 
         ( Command.debug_log_command_argument_mismatch model
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




