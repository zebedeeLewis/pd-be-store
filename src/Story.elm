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



type Model = Story State Store.Model User.Model
-- type Model = Story Store.Model User.Model



type State
  = WaitingForRequestedCatalog
  | WaitingFroUserAction



create_blank_story : Model
create_blank_story =
  Story WaitingFroUserAction
        Store.create_new_empty_store
        User.create_new_guest_with_empty_cart



dispatch_message__catalogPageRequest
  :  (rootModel -> Model)
  -> (Model -> rootModel -> rootModel)
  -> Catalog.PageNumber
  -> Message.Msg rootModel
dispatch_message__catalogPageRequest
  get_story_from
  set_story_to
  pageNumber =
  let handler = handle__catalogPageRequest get_story_from set_story_to
  in Message.dispatch_message__catalogPageRequest handler pageNumber



handle__catalogPageRequest
  :  (rootModel -> Model)
  -> (Model -> rootModel -> rootModel)
  -> Message.RequestCatalogPageHandler rootModel
handle__catalogPageRequest
  produce_story
  set_story_to
  pageNumber
  rootModel =
  let updatedStory =
        rootModel
          |> produce_story
          |> set_state_to WaitingForRequestedCatalog

      updatedRootModel = rootModel |> set_story_to updatedStory

  in ( updatedRootModel
     , Api.get_items_where (Query.page_number_equals pageNumber)
     )



set_state_to : State -> Model -> Model
set_state_to state story =
  let user = get_user_from story
      store = get_store_from story
  in Story state store user



set_store_to : Store.Model -> Model -> Model
set_store_to store story =
  let user = get_user_from story
      state = get_state_from story
  in Story state store user



use_gst : Store.GST -> Model -> Model
use_gst newGst story =
  let updatedStore = 
        get_store_from story
          |> Store.set_gst_to newGst

  in story |> set_store_to updatedStore



get_user_from : Model -> User.Model
get_user_from (Story _ _ user) = user



get_store_from : Model -> Store.Model
get_store_from (Story _ store _) = store



get_state_from : Model -> State
get_state_from (Story state _ _) = state

