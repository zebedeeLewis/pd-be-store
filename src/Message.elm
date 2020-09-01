module Message exposing
  ( Model
  , Arguments
  , Handler
  , new
  , handle
  , unwrap_url_changed_arguments
  , wrap_url_changed_arguments
  , unwrap_link_clicked_arguments
  , wrap_link_clicked_arguments
  , unwrap_catalog_page_request_arguments
  , wrap_catalog_page_request_arguments
  , debug_log_message_argument_mismatch
  )

import Url
import Browser
import Catalog



type Model model = Msg (Handler model) Arguments

type alias Handler model =
  Arguments -> model -> ( model, Cmd (Model model))

type Arguments
  = UrlChangedArgs Url.Url
  | LinkClickedArgs Browser.UrlRequest
  | LoadCatalogPageArgs Int



new : Handler model -> Arguments -> Model model
new handler arguments = Msg handler arguments



handle : Model model -> model -> (model, Cmd (Model model))
handle message model =
  let (Msg action arguments) = message
  in action arguments model



debug_log_message_argument_mismatch : model -> model
debug_log_message_argument_mismatch model =
  Debug.log "Wrong Message.Argument passed to Message.Model" model



wrap_url_changed_arguments : Url.Url -> Arguments
wrap_url_changed_arguments url = UrlChangedArgs url



wrap_link_clicked_arguments : Browser.UrlRequest -> Arguments
wrap_link_clicked_arguments urlRequest = LinkClickedArgs urlRequest



wrap_catalog_page_request_arguments : Catalog.PageNumber -> Arguments
wrap_catalog_page_request_arguments pageNumber =
  LoadCatalogPageArgs pageNumber



unwrap_catalog_page_request_arguments
  :  Arguments
  -> Maybe Catalog.PageNumber
unwrap_catalog_page_request_arguments arguments =
  case arguments of
    LoadCatalogPageArgs pageNumber -> Just pageNumber
    _ -> Nothing



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


