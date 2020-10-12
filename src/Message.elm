module Message exposing
  ( Msg
  , UrlChangedHandler
  , LinkClickedHandler
  , RequestCatalogPageHandler
  , update_rootModel
  , dispatch_message__linkClicked
  , dispatch_message__urlChanged
  , dispatch_message__catalogPageRequest
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


-- Message Handler Aliases

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



-- Message Dispatch Functions

dispatch_message__urlChanged
  :  UrlChangedHandler rootModel
  -> Url.Url 
  -> Msg rootModel
dispatch_message__urlChanged handler url =
  UrlChanged handler url



dispatch_message__linkClicked
  :  LinkClickedHandler rootModel
  -> Browser.UrlRequest 
  -> Msg rootModel
dispatch_message__linkClicked handler urlRequest =
  LinkClicked handler urlRequest



dispatch_message__catalogPageRequest
  :  RequestCatalogPageHandler rootModel
  -> Catalog.PageNumber 
  -> Msg rootModel
dispatch_message__catalogPageRequest handler pageNumber =
  RequestCatalogPage handler pageNumber
