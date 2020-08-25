module Discount exposing
  ( Model
  , Error(..)
  , create_new_discount
  , produce_percentage_of
  , apply_discount_to_price
  , produce_random_discount_from_seed
  , json_encode
  , decode_json
  , get_code_for
  , javascript_representation_of
  , decoder
  )


import Json.Encode as Encode
import Json.Decode as Decode
import Time
import UUID
import Random
import SRandom


{-| A discount encapsulates a percentage reduction on an items list
price as well as additional marketing and management information.

Each discount is identified by a unique "discount code". No other
discount should have this code.

The discount scope is a list of ids referencing the items a given
discount applies to.

While mulitiple discounts can reference a single item, only one discount
can be applied to an item when sold. The discount that provides the most
benefit to the user should be the one applied.


example:

  expires = Time.millisToPosix 1597964420
  itemDiscount : Model
  itemDiscount =
    Discount "UXDS9y3" "seafood giveaway" 15 ["CHKCCS1233"] expires
-}
type Model = Discount Code Description Percentage Scope ExpirationDate

type alias Code = String
type alias Description = String
type alias Percentage = Int
type alias Scope = List String
type alias ExpirationDate = Time.Posix



create_new_discount
  :  Code
  -> Description
  -> Percentage
  -> Scope
  -> Int
  -> Model
create_new_discount code description percentage scope date = 
  Discount code description percentage scope (Time.millisToPosix date)



javascript_representation_of : Model -> Encode.Value
javascript_representation_of discount = 
  let (Discount code description percentage scope expires) = discount
  in Encode.object
       [ ( "code", Encode.string code )
       , ( "description", Encode.string description )
       , ( "percentage", Encode.int percentage )
       , ( "scope", Encode.list Encode.string scope )
       , ( "expiration_date"
         , Encode.int <| Time.posixToMillis expires
         )
       ]



json_encode : Model -> String
json_encode discount =
  let value = javascript_representation_of discount
  in Encode.encode 0 value



scopeDecoder : Decode.Decoder (List String)
scopeDecoder = Decode.list Decode.string



decoder : Decode.Decoder Model
decoder = Decode.map5
            create_new_discount
            ( Decode.field "code" Decode.string )
            ( Decode.field "description" Decode.string )
            ( Decode.field "percentage" Decode.int )
            ( Decode.field "scope" scopeDecoder )
            ( Decode.field "expiration_date" Decode.int )
              


decode_json : String -> Result Decode.Error Model
decode_json jsonDiscount =
  Decode.decodeString decoder jsonDiscount



get_code_for : Model -> String
get_code_for discount =
  let (Discount code description percentage scope expires) = discount
  in code



produce_percentage_of : Model -> Int
produce_percentage_of discount =
  let (Discount _ _ percentage _ _) = discount
  in percentage



apply_discount_to_price : Float -> Model -> Float
apply_discount_to_price price discount =
  let produce_discounted_amount_on_price_ =
        produce_discounted_amount_on_price price
      subtract_it_from_price = (-) price
  in discount
       |> produce_discounted_amount_on_price_
       |> subtract_it_from_price



produce_discounted_amount_on_price : Float -> Model -> Float
produce_discounted_amount_on_price price discount =
  let percentage = produce_percentage_of discount |> toFloat
  in (percentage/100)*price



type Error
  = ValueError String
  | DateError String



-- DUMMY DATA

produce_random_discount_from_seed : Int -> Model
produce_random_discount_from_seed seed =
  Discount
    (SRandom.produce_random_id seed)
    (SRandom.produce_random_description seed)
    (SRandom.randomInt 1 25 seed)
    (List.map
      (\i -> SRandom.produce_random_id (seed+i)) (List.range 0 8)
    )
    ((SRandom.randomInt 8888 9999 seed) |> Time.millisToPosix)
  
