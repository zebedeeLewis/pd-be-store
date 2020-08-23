module Discount exposing
  ( Model
  , Data
  , Error(..)
  , create_new_discount
  , produce_data_from
  , forcefully_produce_discount_from_data
  , validate_data
  , produce_percentage_of
  , apply_discount_to_price
  , produce_random_discount_from_seed
  , produce_random_data_from_seed
  , json_encode
  , decode_json
  , get_code_for
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



type alias Data =
  { code            : Code
  , description     : Description
  , percentage      : String
  , scope           : Scope
  , expiration_date : String
  }



create_new_discount
  :  Code
  -> Description
  -> Percentage
  -> Scope
  -> Int
  -> Model
create_new_discount code description percentage scope date = 
  Discount code description percentage scope (Time.millisToPosix date)



produce_data_from : Model -> Data
produce_data_from discount =
  let (Discount code description percentage scope expire) = discount
  in { code            = code
     , description     = description
     , percentage      = String.fromInt percentage
     , scope           = scope
     , expiration_date = String.fromInt <| Time.posixToMillis expire
     }



forcefully_produce_discount_from_data : Data -> Model
forcefully_produce_discount_from_data data = 
  let should_we_get_invalid_data = -999  -- random number
      just_unwrap_value assumedToBeValid = 
        case assumedToBeValid of
          Just value -> value
          Nothing -> should_we_get_invalid_data

      percentage =
        .percentage data |> String.toInt |> just_unwrap_value

      expiration_date =
        .expiration_date data
          |> String.toInt
          |> just_unwrap_value
          |> Time.millisToPosix

  in Discount
       (.code data)
       (.description data)
       (percentage) 
       (.scope data)
       (expiration_date)



produce_discount_from_data : Data -> Result Error Model
produce_discount_from_data data = 
  case validate_data data of
    Err error -> Err error
    Ok _ -> Ok <| forcefully_produce_discount_from_data data



encoder : Model -> Encode.Value
encoder discount = 
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
  let (Discount code description percentage scope expires) = discount
      value = encoder discount
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
              


decode_json : String -> Result Error Model
decode_json jsonDiscount =
  let decodeResult = Decode.decodeString decoder jsonDiscount
  in case decodeResult of
       Err error -> Err <| JsonDecodeError error
       Ok discount -> Ok discount



validate_data : Data -> Result Error Data
validate_data data =
  let percentage_error =
        ValueError "Discount value needs to be an Integer."
      expiration_date_error =
        DateError "Discount expiration date needs to be an Integer."
  in case .percentage data |> String.toInt of
       Nothing -> Err percentage_error
       Just percentage ->
         case .expiration_date data |> String.toInt of
           Nothing -> Err expiration_date_error
           Just expiration_date -> Ok data



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
  | JsonDecodeError Decode.Error
  | DateError String



-- DUMMY DATA

produce_random_data_from_seed : Int -> Data
produce_random_data_from_seed seed =
  let discount = produce_random_discount_from_seed seed
  in produce_data_from discount



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
  
