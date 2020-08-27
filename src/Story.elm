module Story exposing
  ( Model
  , create_blank_story
  , use_gst
  )

import User
import ShoppingList
import Command
import Store
import Catalog



type Model = Story Store.Model User.Model



create_blank_story : Model
create_blank_story =
  Story Store.create_new_empty_store
        User.create_new_guest_with_empty_cart



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


