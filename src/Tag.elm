module Tag exposing
  ( Model
  , Data
  , Error(..)
  , encode_data
  , decode_tag
  , forcefully_encode_data
  , produce_random_tag_from_seed
  )

import Json.Encode as Encode
import Json.Decode as Decode
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



create_tag : UniqueName -> Class -> Description -> Model
create_tag name class description = Tag name class description



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



javascript_representation_of : Model -> Encode.Value
javascript_representation_of tag = 
  let (Tag name class description) = tag
  in Encode.object
       [ ( "name", Encode.string name )
       , ( "class", Encode.string class )
       , ( "description", Encode.string description )
       ]



json_encode : Model -> String
json_encode tag =
  let value = javascript_representation_of tag
  in Encode.encode 0 value



decoder : Decode.Decoder Model
decoder = Decode.map3
            create_tag
            ( Decode.field "name" Decode.string )
            ( Decode.field "class" Decode.string )
            ( Decode.field "description" Decode.string )
              


decode_json : String -> Result Decode.Error Model
decode_json jsonTag =
  Decode.decodeString decoder jsonTag



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

