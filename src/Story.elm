module Story exposing
  ( Model
  , create_blank_story
  , use_gst
  )

import User
import ShoppingList
import Message
import Store
import Catalog
import Api
import Api.Query as Query



-- type Model = Story State Store.Model User.Model
type Model = Story Store.Model User.Model



type State 
  = WaitingForRequestedCatalog



create_blank_story : Model
create_blank_story =
  Story Store.create_new_empty_store
        User.create_new_guest_with_empty_cart



dispatch_request_catalog_page_message
  :  (rootModel -> Model)
  -> (Model -> rootModel)
  -> Catalog.PageNumber
  -> Message.Msg rootModel
dispatch_request_catalog_page_message
  get_story_from
  set_story_to
  pageNumber =
  let handler =
        handle_catalog_page_request get_story_from set_story_to
  in Message.dispatch_request_catalog_page_message handler pageNumber



handle_catalog_page_request
  :  (rootModel -> Model)
  -> (Model -> rootModel)
  -> Message.RequestCatalogPageHandler rootModel
handle_catalog_page_request
  get_story_from
  set_story_to
  pageNumber
  rootModel =
  -- Api.get_items_where Query.page_number_equals 
  Debug.todo "TODO!!!"



set_state_to : State -> Model -> Model
set_state_to state story =
  Debug.todo "TODO!!!"



set_store_to : Store.Model -> Model -> Model
set_store_to store story =
  let user = get_user_from story
  in Story store user



use_gst : Store.GST -> Model -> Model
use_gst newGst story =
  let updatedStore = 
        get_store_from story
          |> Store.set_gst_to newGst

  in story |> set_store_to updatedStore



get_user_from : Model -> User.Model
get_user_from (Story _ user) = user



get_store_from : Model -> Store.Model
get_store_from (Story store _) = store


