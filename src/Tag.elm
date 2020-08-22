module Tag exposing
  ( Model
  , Data
  , Error(..)
  , encode_data
  , decode_tag
  , forcefully_encode_data
  , produce_random_tag_from_seed
  )

import Random
import SRandom



{-| Tags gives us a flexible way of organizing and grouping items.
Tags can be used to group items into departments, categories, or even
search groups. Each tag is identified by a unique human readable name
and belongs to a class.
-}
type Model = Tag UniqueName Class Description


type alias UniqueName  = String
type alias Description = String
type alias Class       = String



type alias Data =
  { name        : UniqueName
  , class       : Class
  , description : Description
  }



encode_data : Data -> Result Error Model
encode_data data =
  if (.name data |> String.length) < 1
    then Err <| NullName data
    else Ok <| Tag (.name data) (.class data) (.description data)



forcefully_encode_data : Data -> Model
forcefully_encode_data data =
  Tag (.name data) (.class data) (.description data)



decode_tag : Model -> Data
decode_tag (Tag name class description) =
  { name        = name
  , class       = class
  , description = description
  }



type Error = NullName Data


-- DUMMY DATA

produce_random_tag_from_seed : Int -> Model
produce_random_tag_from_seed seed =
  Tag (produce_random_name_from_seed seed)
      (produce_random_class_from_seed seed)
      (SRandom.produce_random_description seed)



produce_random_class_from_seed : Int -> Class
produce_random_class_from_seed seed =
  case (SRandom.randomInt 1 4 seed) of
    1 -> "department"
    2 -> "category"
    3 -> "subcategory"
    _ -> "search"



produce_random_name_from_seed : Int -> Class
produce_random_name_from_seed seed =
  case (SRandom.randomInt 1 4 seed) of
    1 -> "seafood"
    2 -> "beach wear"
    3 -> "fresh produce"
    _ -> "refrigerated"

