module Availability exposing
  ( Model
  , Error
  , stringify
  , parse
  , forcefully_parse
  , out_of_stock
  , produce_random_availability_from_seed
  , unknown
  )

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



parse : String -> Result Error Model
parse availabilityData =
  let errorMessage = "I can't parse an availability from this string"
  in case availabilityData |> String.toLower |> String.trim of
       "in_stock"    -> Ok IN_STOCK
       "out_stock"   -> Ok OUT_STOCK
       "order_only"  -> Ok ORDER_ONLY
       _             -> Err <| ParseError errorMessage availabilityData



forcefully_parse : String -> Model
forcefully_parse availabilityData =
  case availabilityData |> String.toLower |> String.trim of
    "in_stock"    -> IN_STOCK
    "order_only"  -> ORDER_ONLY
    "out_stock"   -> OUT_STOCK
    _             -> Unknown



type Error = ParseError String String



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


