module Message exposing
  ( Msg
  , UrlChangedHandler
  , LinkClickedHandler
  , RequestCatalogPageHandler
  , update_rootModel
  , dispatch_link_clicked_message
  , dispatch_url_changed_message
  , dispatch_request_catalog_page_message
  )

import Url
import Browser
import Catalog



{-| all messages sent by the system should be defined in this functions.
Each message controller should follow the following pattern:
<MessageName> <Handler> <... HandlerArgs>

The rootModel refers to the main application model. The Handler should
extract the sub-model it is specifically designed for from the
rootModel, update the sub-model, update the rootModel with the updated
sub-model and return the new updated rootModel.
-}
type Msg rootModel
  = UrlChanged (UrlChangedHandler rootModel) Url.Url
  | LinkClicked (LinkClickedHandler rootModel) Browser.UrlRequest
  | RequestCatalogPage
      (RequestCatalogPageHandler rootModel)
      Catalog.PageNumber



type alias UrlChangedHandler rootModel =
 (Url.Url -> rootModel -> (rootModel, Cmd (Msg rootModel)))



type alias LinkClickedHandler rootModel =
  ( Browser.UrlRequest
  -> rootModel
  -> (rootModel, Cmd (Msg rootModel))
  )



type alias RequestCatalogPageHandler rootModel =
  ( Catalog.PageNumber
  -> rootModel
  -> (rootModel, Cmd (Msg rootModel))
  )



update_rootModel
  : Msg rootModel
  -> rootModel
  -> (rootModel, Cmd (Msg rootModel))
update_rootModel message rootModel =
  case message of
    (UrlChanged handler url) ->
      handler url rootModel

    (LinkClicked handler urlRequest) ->
      handler urlRequest rootModel

    (RequestCatalogPage handler pageNumber) ->
      handler pageNumber rootModel 



dispatch_url_changed_message
  :  UrlChangedHandler rootModel
  -> Url.Url 
  -> Msg rootModel
dispatch_url_changed_message handler url =
  UrlChanged handler url



dispatch_link_clicked_message
  :  LinkClickedHandler rootModel
  -> Browser.UrlRequest 
  -> Msg rootModel
dispatch_link_clicked_message handler urlRequest =
  LinkClicked handler urlRequest



-- TODO change name to dispatch_message__request_catalog_page
dispatch_request_catalog_page_message
  :  RequestCatalogPageHandler rootModel
  -> Catalog.PageNumber 
  -> Msg rootModel
dispatch_request_catalog_page_message handler pageNumber =
  RequestCatalogPage handler pageNumber







-- type Model model = Msg (Handler model) Arguments
-- 
-- type alias Handler model =
--   Arguments -> model -> ( model, Cmd (Model model))
-- 
-- type Arguments
--   = UrlChangedArgs Url.Url
--   | LinkClickedArgs Browser.UrlRequest
--   | RequestCatalogPageArgs Int
-- 
-- 
-- 
-- new : Handler model -> Arguments -> Model model
-- new handler arguments = Msg handler arguments
-- 
-- 
-- 
-- handle : Model model -> model -> (model, Cmd (Model model))
-- handle message model =
--   let (Msg action arguments) = message
--   in action arguments model
-- 
-- 
-- 
-- debug_log_message_argument_mismatch : model -> model
-- debug_log_message_argument_mismatch model =
--   Debug.log "Wrong Message.Argument passed to Message.Model" model
-- 
-- 
-- 
-- wrap_url_changed_arguments : Url.Url -> Arguments
-- wrap_url_changed_arguments url = UrlChangedArgs url
-- 
-- 
-- 
-- wrap_link_clicked_arguments : Browser.UrlRequest -> Arguments
-- wrap_link_clicked_arguments urlRequest = LinkClickedArgs urlRequest
-- 
-- 
-- 
-- wrap_catalog_page_request_arguments : Catalog.PageNumber -> Arguments
-- wrap_catalog_page_request_arguments pageNumber =
--   RequestCatalogPageArgs pageNumber
-- 
-- 
-- 
-- unwrap_catalog_page_request_arguments
--   :  Arguments
--   -> Maybe Catalog.PageNumber
-- unwrap_catalog_page_request_arguments arguments =
--   case arguments of
--     RequestCatalogPageArgs pageNumber -> Just pageNumber
--     _ -> Nothing
-- 
-- 
-- 
-- unwrap_url_changed_arguments : Arguments -> Maybe Url.Url
-- unwrap_url_changed_arguments arguments =
--   case arguments of
--     UrlChangedArgs url -> Just url
--     _ -> Nothing
-- 
-- 
-- 
-- unwrap_link_clicked_arguments : Arguments -> Maybe Browser.UrlRequest
-- unwrap_link_clicked_arguments arguments =
--   case arguments of
--     LinkClickedArgs urlRequest -> Just urlRequest
--     _ -> Nothing
-- 
-- 
