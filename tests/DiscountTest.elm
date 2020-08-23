module DiscountTest exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)

import Time
import SRandom
import Json.Encode as E
import Discount


-------------------------------------------------------------------------
-- CONSTANTS DATA
-------------------------------------------------------------------------

it = test

code = "DISC123ABC"

description = "test discount"

percentage = 12

scope = [ "ABCDISCOUNT" ]

expirationDate = 99999

testDiscount =
  Discount.create_new_discount
    code
    description
    percentage
    scope
    expirationDate

encodedDiscount
  =  "{"
  ++ "\"code\":\"" ++ (code) ++ "\""
  ++ ",\"description\":" ++ (E.encode 0 <| E.string description)
  ++ ",\"percentage\":" ++ (E.encode 0 <| E.int percentage)
  ++ ",\"scope\":" ++ (E.encode 0 <| E.list E.string scope)
  ++ ",\"expiration_date\":" ++ (E.encode 0 <| E.int expirationDate)
  ++ "}"


-------------------------------------------------------------------------
-- SAMPLE DATA
-------------------------------------------------------------------------

enable = todo "Enable Item Tests"



-------------------------------------------------------------------------
-- TESTS
-------------------------------------------------------------------------

json_encode =
  describe "json_encode"
    [ it "converts a Discount to a JSON object"
         (\_ ->
           let expected = encodedDiscount
               actual = Discount.json_encode testDiscount
           in Expect.equal expected actual
         )
    ]



json_decode =
  describe "json_decode"
    [ it "converts a JSON encoded Discount to a Discount value"
         (\_ ->
           let expected = testDiscount
               discount = Discount.decode_json encodedDiscount
           in case discount of
                Err _ -> Expect.false "parsing error" False
                Ok actual -> Expect.equal expected actual
         )
    ]

