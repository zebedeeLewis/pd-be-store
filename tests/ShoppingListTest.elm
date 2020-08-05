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



-----------------------------------------------------------------------
-- TESTS
-----------------------------------------------------------------------

addItem =
  describe "add"
    [ it "creates new entry if item is not found in the shopping list."
      <| \_->
           Expect.equal
             (ShoppingList.add itemId emptyList)
             (ShoppingList.ShoppingList 
               [ShoppingList.Entry 1 itemId])

    , it ("increments the quantity of the entry for each " ++
          "subsequent entry of the same item.")
      <| \_->
           Expect.equal
             (ShoppingList.add itemId
             << ShoppingList.add itemId
             << ShoppingList.add itemId <| emptyList)
             (ShoppingList.ShoppingList 
               [ShoppingList.Entry 3 itemId])
    ]


removeItem =
  describe "remove"
    [ it ("removes the entry w/ the given id from the list if the " ++
          "the entrys quantity value is 1.")
      (\_->
        Expect.equal
          (ShoppingList.remove
             itemId 
             <| ShoppingList.ShoppingList 
                  [ShoppingList.Entry 1 itemId])
          (ShoppingList.ShoppingList [])
      )

    , it ("decrement the quantity value of the entry w/ the given " ++
          "id by 1 if the its quantity value is greater than 1.")
      (\_->
        Expect.equal
          (ShoppingList.remove
             itemId 
             <| ShoppingList.ShoppingList [ShoppingList.Entry 5 itemId])
          (ShoppingList.ShoppingList [ShoppingList.Entry 4 itemId])
      )
    ]


total =
  describe "total"
    [ it ("produces the total or sub-total of all items in the " ++
          "list.")
      ( \_->
         (8, 25) |>
         Expect.equal
           ( ShoppingList.total 
               (\id ->
                 case id of
                   "CHKCCS1233" -> (2, 50)
                   _            -> (3, 25)
               )
               ( ShoppingList.ShoppingList
                   [ ShoppingList.Entry 1 "CHKCCS4563"
                   , ShoppingList.Entry 2 "CHKCCS1233"
                   ]
               )
           )
      )
    ]

