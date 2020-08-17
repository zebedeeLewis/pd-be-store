module ShoppingListTest exposing (..)

import Set

import Expect exposing (Expectation)
import Test exposing (..)

import Item
import ShoppingList


-----------------------------------------------------------------------
-- CONSTANTS DATA
-----------------------------------------------------------------------

it = test



-----------------------------------------------------------------------
-- SAMPLE DATA
-----------------------------------------------------------------------

emptyList = ShoppingList.empty 12

itemSummaryData : Item.SummaryDataR
itemSummaryData =
  { name            = "chicken legs"
  , id              = "CHKCCS1233"
  , imageThumbnail  = "https://www.example.com/chicken.jpg"
  , brand           = "caribbean chicken"
  , variant         = "bag"
  , listPrice       = "15.93"
  , size            = "1000.5 mg"
  , departmentTags  = [ { id = "UID789"
                        , name = "deptTag"
                        }
                      ]
  , categoryTags    = [ { id = "UID456"
                        , name = "catTag"
                        }
                      ]
  , subCategoryTags = [ { id   = "UID4123"
                        , name = "subCatTag"
                        }
                      ]
  , searchTags      = [ { id   = "UID333"
                        , name = "searchTag"
                        }
                      ]
  , availability    = "in_stock"
  , discount        = Just { discount_code = "UXDS9y3"
                           , name          = "seafood giveaway"
                           , value         = "15"
                           , items         = ["CHKCCS1233"]
                           }
  }

itemSummary : Item.Model
itemSummary =
  case Item.newSummary itemSummaryData of
    Ok itemSummary_ -> itemSummary_
    Err _ -> Item.blankSummary



-----------------------------------------------------------------------
-- TESTS
-----------------------------------------------------------------------

{-| To enable tests:

1. uncomment the tests below
2. uncomment the test exports from the ShoppingList module
-}
-- enable = todo "Enable ShoppingList Tests"

addItem =
  describe "add"
    [ it "creates new entry if item is not found in the shopping list."
      <| \_->
           Expect.equal
             (ShoppingList.add itemSummary emptyList)
             (ShoppingList.fromListOfItems 12 [itemSummary])

    , it ("increments the quantity of the entry for each " ++
          "subsequent entry of the same item.")
      <| \_->
           Expect.equal
             (ShoppingList.add itemSummary
             << ShoppingList.add itemSummary
             << ShoppingList.add itemSummary <| emptyList)
             (ShoppingList.fromListOfItems 12 <|List.repeat 3 itemSummary)
    ]


removeItem =
  describe "remove"
    [ it ("removes the entry w/ the given id from the list if the " ++
          "the entrys quantity value is 1.")
      (\_->
        Expect.equal
          (ShoppingList.remove (Item.id itemSummary)
             <| ShoppingList.fromListOfItems 12
                  (List.repeat 1 itemSummary))
          (ShoppingList.empty 12)
      )

    , it ("decrement the quantity value of the entry w/ the given " ++
          "id by 1 if the its quantity value is greater than 1.")
      (\_->
        Expect.equal
          (ShoppingList.remove (Item.id itemSummary)
             <| ShoppingList.fromListOfItems 12
                  (List.repeat 5 itemSummary))
          (ShoppingList.fromListOfItems 12 (List.repeat 4 itemSummary))
      )
    ]


total =
  describe "total"
    [ todo ("produces the total or sub-total of all items in the " ++
          "list.")
    ]

