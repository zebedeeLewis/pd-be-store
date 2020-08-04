module ShoppingListTest exposing (..)

import Set

import Expect exposing (Expectation)
import Test exposing (..)

import ItemSummary
import ShoppingList


-----------------------------------------------------------------------
-- CONSTANTS DATA
-----------------------------------------------------------------------

it = test



-----------------------------------------------------------------------
-- SAMPLE DATA
-----------------------------------------------------------------------

emptyList = ShoppingList.empty

itemId = "CHKCCS1233"

itemPrice = 55.99


-----------------------------------------------------------------------
-- TESTS
-----------------------------------------------------------------------

addItem =
  describe "addItem"
    [ it ("should create a new entry if item is not found in the " ++
          "shopping list.")
      <| \_->
           Expect.equal
             (ShoppingList.add itemId itemPrice emptyList)
             (ShoppingList.ShoppingList 
               [ShoppingList.Entry 1 itemPrice itemId])

    , it ("should increment the quantity of the entry for each " ++
          "subsequent entry of the same item.")
      <| \_->
           Expect.equal
             (ShoppingList.add itemId itemPrice
             << ShoppingList.add itemId itemPrice
             << ShoppingList.add itemId itemPrice <| emptyList)
             (ShoppingList.ShoppingList 
               [ShoppingList.Entry 3 itemPrice itemId])

    , it ("should always update the price of the entry to that of " ++
          "the new item.")
      <| \_->
           let finalPrice = 2.50
           in
             Expect.equal
               (ShoppingList.add itemId finalPrice <|
                 ShoppingList.ShoppingList 
                   [ShoppingList.Entry 1 itemPrice itemId])

               (ShoppingList.ShoppingList 
                 [ShoppingList.Entry 2 finalPrice itemId])
    ]

