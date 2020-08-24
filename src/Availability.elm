module Availability exposing
  ( Model
  , stringify
  , parse
  , out_of_stock
  , produce_random_availability_from_seed
  , unknown
  )

import Json.Encode as Encode
import Json.Decode as Decode
import Random


{-| The availability status of an item lets users know if an item is in
stock, out of stock, or if its available on an order only basis.
-}
type Model
  = IN_STOCK
  | ORDER_ONLY
  | OUT_STOCK
  | Unknown



out_of_stock : Model
out_of_stock = OUT_STOCK



in_stock : Model
in_stock = IN_STOCK



order_only : Model
order_only = ORDER_ONLY



unknown : Model
unknown = Unknown



stringify : Model -> String
stringify availability =
  case availability of
    IN_STOCK      -> "in_stock"    
    OUT_STOCK     -> "out_stock"   
    ORDER_ONLY    -> "order_only"  
    Unknown -> "out_stock" 



javascript_representation_of : Model -> Encode.Value
javascript_representation_of availability =
  let availabilityString = stringify availability
  in Encode.string availabilityString



json_encode : Model -> String
json_encode availability =
  let value = javascript_representation_of availability
  in Encode.encode 0 value



decoder : Decode.Decoder Model
decoder = Decode.map parse Decode.string



decode_json : String -> Result Decode.Error Model
decode_json jsonAvailability =
  Decode.decodeString decoder jsonAvailability



parse : String -> Model
parse availabilityData =
  case availabilityData |> String.toLower |> String.trim of
    "in_stock"    -> IN_STOCK
    "out_stock"   -> OUT_STOCK
    "order_only"  -> ORDER_ONLY
    _             -> Unknown



-- DUMMY DATA

produce_random_availability_from_seed : Int -> Model
produce_random_availability_from_seed seed =
  let mapper x =
        case x of
          1 -> IN_STOCK
          2 -> OUT_STOCK
          _ -> ORDER_ONLY
      generator = Random.map mapper (Random.int 1 3)
  in Random.step generator (Random.initialSeed seed) |> Tuple.first


