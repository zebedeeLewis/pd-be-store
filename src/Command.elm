module Command exposing
  ( Msg
  , Arguments
  , Action
  , new
  , execute
  , unwrap_url_changed_arguments
  , wrap_url_changed_arguments
  , unwrap_link_clicked_arguments
  , wrap_link_clicked_arguments
  , debug_log_command_argument_mismatch
  )

import Url
import Browser



type Msg model = Command (Action model) Arguments

type alias Action model =
  Arguments -> model -> ( model, Cmd (Msg model))

type Arguments
  = UrlChangedArgs Url.Url
  | LinkClickedArgs Browser.UrlRequest



new : Action model -> Arguments -> Msg model
new action args = Command action args



execute : Msg model -> model -> (model, Cmd (Msg model))
execute command model =
  let (Command action arguments) = command
  in action arguments model



debug_log_command_argument_mismatch : model -> model
debug_log_command_argument_mismatch model =
  Debug.log "Wrong Command.Argument passed to Command.Msg" model



wrap_url_changed_arguments : Url.Url -> Arguments
wrap_url_changed_arguments url = UrlChangedArgs url



wrap_link_clicked_arguments : Browser.UrlRequest -> Arguments
wrap_link_clicked_arguments urlRequest = LinkClickedArgs urlRequest



unwrap_url_changed_arguments : Arguments -> Maybe Url.Url
unwrap_url_changed_arguments arguments =
  case arguments of
    UrlChangedArgs url -> Just url
    _ -> Nothing



unwrap_link_clicked_arguments : Arguments -> Maybe Browser.UrlRequest
unwrap_link_clicked_arguments arguments =
  case arguments of
    LinkClickedArgs urlRequest -> Just urlRequest
    _ -> Nothing


