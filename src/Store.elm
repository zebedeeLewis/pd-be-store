module Store exposing
  ( Model
  , GST
  , get_gst_from_store
  , create_new_empty_store
  , set_gst_to
  )

import Catalog


type Model = Store GST Catalog.Model

type alias GST = Float



create_new_empty_store : Model
create_new_empty_store =
  Store 0.0 (Catalog.create_new_page 0 0 [])



get_gst_from_store : Model -> GST
get_gst_from_store (Store gst _) = gst



set_gst_to : GST -> Model -> Model
set_gst_to newGst (Store _ catalog) =
  Store newGst catalog


