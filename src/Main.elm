module Main exposing (..)

import Url
import Time
import Task
import Html exposing (Html)
import Html.Styled exposing (toUnstyled)
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



init : () -> Url.Url -> Nav.Key -> (Model, Cmd (Command.Msg Model))
init  _ url key =
  ( { story = Story.create_blank_story
    , view  = View.loadingView
    , route = Route.produce_route_to_search_results_page
    }
  , Cmd.none
  )



view : Model -> Browser.Document (Command.Msg Model)
view model =
  { title = "test" , body = [ Html.div [] [] ] }
  -- { title = "test" , body = View.viewBody model.view model.story }



update : Command.Msg Model -> Model -> (Model, Cmd (Command.Msg Model))
update command model =
  ( Command.execute command model
  , Cmd.none
  )



url_change_command : Url.Url -> Command.Msg Model
url_change_command url =
  let urlChangedArgs = Command.wrap_url_changed_arguments url
  in Command.new handle_url_change urlChangedArgs



link_clicked_command : Browser.UrlRequest -> Command.Msg Model
link_clicked_command urlRequest =
  let linkClickedArgs = Command.wrap_link_clicked_arguments urlRequest
  in Command.new handle_link_clicked linkClickedArgs



{-| TODO!!! -}
handle_url_change : Command.Arguments -> Model -> Model
handle_url_change args model =
  let possibleUrl = Command.unwrap_url_changed_arguments args
  in case possibleUrl of
       Nothing -> Command.debug_log_command_argument_mismatch model
       Just url -> model



{-| TODO!!! -}
handle_link_clicked : Command.Arguments -> Model -> Model
handle_link_clicked args model =
  let possibleUrlRequest = Command.unwrap_link_clicked_arguments args
  in case possibleUrlRequest of
       Nothing -> Command.debug_log_command_argument_mismatch model
       Just urlRequest -> model



defaultTax = 12.4



