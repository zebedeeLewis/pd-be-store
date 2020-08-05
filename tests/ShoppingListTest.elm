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
item2Id = "CHKCCS4563"

itemPrice = 55.99


-----------------------------------------------------------------------
-- TESTS
-----------------------------------------------------------------------

addItem =
  describe "add"
    [ it "creates new entry if item is not found in the shopping list."
      <| \_->
           Expect.equal
             (ShoppingList.add itemId itemPrice emptyList)
             (ShoppingList.ShoppingList 
               [ShoppingList.Entry 1 itemPrice itemId])

    , it ("increments the quantity of the entry for each " ++
          "subsequent entry of the same item.")
      <| \_->
           Expect.equal
             (ShoppingList.add itemId itemPrice
             << ShoppingList.add itemId itemPrice
             << ShoppingList.add itemId itemPrice <| emptyList)
             (ShoppingList.ShoppingList 
               [ShoppingList.Entry 3 itemPrice itemId])

    , it "updates the price of the entry to that of the new item."
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


removeItem =
  describe "remove"
    [ it ("removes the entry w/ the given id from the list if the " ++
          "the entrys quantity value is 1.")
      (\_->
        Expect.equal
          (ShoppingList.remove
             itemId 
             itemPrice
             <| ShoppingList.ShoppingList 
                  [ShoppingList.Entry 1 itemPrice itemId])
          (ShoppingList.ShoppingList [])
      )

    , it ("decrement the quantity value of the entry w/ the given " ++
          "id by 1 if the its quantity value is greater than 1.")
      (\_->
        Expect.equal
          (ShoppingList.remove
             itemId 
             itemPrice
             <| ShoppingList.ShoppingList 
                  [ShoppingList.Entry 5 itemPrice itemId])
          (ShoppingList.ShoppingList 
            [ShoppingList.Entry 4 itemPrice itemId])
      )
    ]


subTotal =
  describe "subTotal"
    [ it ("produces the sub-total of the price of all items in the " ++
          "list.")
      ( \_->
         (8, 25) |>
         Expect.equal
           ( ShoppingList.subTotal 
               (\id ->
                 case id of
                   "CHKCCS1233" -> (2, 50)
                   _            -> (3, 25)
               )
               ( ShoppingList.ShoppingList
                   [ ShoppingList.Entry 1 3.25 "CHKCCS4563"
                   , ShoppingList.Entry 2 2.50 "CHKCCS1233"
                   ]
               )
           )
      )
    ]

