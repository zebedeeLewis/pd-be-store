module Discount exposing
  ( Model
  , DataV1
  , Data
  , Error(..)
  , create_new_discount
  , produce_data_from
  , produce_discount_from_valid_data
  , validate_discount_data
  , produce_percentage_of
  , apply_discount_to_price
  , produce_random_discount_from_seed
  , produce_random_data_from_seed
  )


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
type Model = Discount Code Description Percentage Scope Expires

type alias Code = String
type alias Description = String
type alias Percentage = Int
type alias Scope = List String
type alias Expires = Time.Posix



type alias DataV1 =
  { discount_code    : Code
  , name             : Description
  , value            : String
  , items            : Scope
  }



type alias Data =
  { code            : Code
  , description     : Description
  , percentage      : String
  , scope           : Scope
  , expiration_date : String
  }



create_new_discount
  : Int
  -> Description
  -> Percentage
  -> Scope
  -> Expires
  -> Model
create_new_discount seed description discount_percentage scope date = 
  create_blank_discount
    |> give_it_a_random_code_from_seed seed
    |> give_it_a_percentage_of discount_percentage
    |> describe_it_as description
    |> make_it_expire_on date
    |> apply_it_to_items_indicated_by_ids_in scope



create_blank_discount : Model
create_blank_discount =
  Discount "" "" 0 [] (Time.millisToPosix 0)



describe_it_as : Description -> Model -> Model
describe_it_as description discount =
  let (Discount code _ percentage scope expires) = discount
  in Discount code description percentage scope expires



give_it_a_percentage_of : Percentage -> Model -> Model
give_it_a_percentage_of discount_percentage discount =
  let (Discount code description _ scope expires) = discount
  in Discount code description discount_percentage scope expires



give_it_a_random_code_from_seed : Int -> Model -> Model
give_it_a_random_code_from_seed seed_value discount =
  let (Discount _ description percentage scope expires) = discount
      code = Random.step UUID.generator (Random.initialSeed seed_value)
               |> Tuple.first
               |> UUID.toString
  in Discount code description percentage scope expires



make_it_expire_on : Expires -> Model -> Model
make_it_expire_on expiration_date discount =
  let (Discount code description percentage scope _) = discount
  in Discount code description percentage scope expiration_date



apply_it_to_items_indicated_by_ids_in : Scope -> Model -> Model
apply_it_to_items_indicated_by_ids_in scope discount =
  let (Discount code description percentage _ expire) = discount
  in Discount code description percentage scope expire



produce_data_from : Model -> Data
produce_data_from discount =
  let (Discount code description percentage scope expire) = discount
  in { code            = code
     , description     = description
     , percentage      = String.fromInt percentage
     , scope           = scope
     , expiration_date = String.fromInt <| Time.posixToMillis expire
     }



produce_discount_from_valid_data : Data -> Model
produce_discount_from_valid_data data = 
  let should_we_get_invalid_data = -999  -- random number
      just_unwrap_value we_assume_its_valid = 
        case we_assume_its_valid of
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



validate_discount_data : Data -> Result Error Data
validate_discount_data data =
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

produce_random_data_from_seed : Int -> Data
produce_random_data_from_seed seed =
  { code             = SRandom.produce_random_id seed
  , description      = SRandom.produce_random_description seed
  , percentage       = String.fromInt (SRandom.randomInt 1 25 seed)
  , scope            = List.map
                         (\i ->
                           let seed_ = seed+i
                           in SRandom.produce_random_id seed_
                         ) <| List.range 0 8
  , expiration_date  = String.fromInt (SRandom.randomInt 8888 9999 seed)
  }



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
  
