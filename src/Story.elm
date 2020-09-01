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



type Model = Story Store.Model User.Model



create_blank_story : Model
create_blank_story =
  Story Store.create_new_empty_store
        User.create_new_guest_with_empty_cart



dispatch_catalog_page_request_message
  :  (Model -> rootModel -> rootModel)
  -> Catalog.PageNumber
  -> Message.Model rootModel
dispatch_catalog_page_request_message update_root_model pageNumber =
  let messageArguments =
        Message.wrap_catalog_page_request_arguments pageNumber
      handle_catalog_page_request_ = 
        handle_catalog_page_request update_root_model

  in Message.new handle_catalog_page_request_ messageArguments



handle_catalog_page_request
  : (Model -> rootModel -> rootModel)
  -> Message.Handler rootModel
handle_catalog_page_request update_root_model args rootModel =
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


