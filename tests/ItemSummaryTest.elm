module ItemSummaryTest exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)

import ItemSummary


-----------------------------------------------------------------------
-- CONSTANTS DATA
-----------------------------------------------------------------------

it = test



-----------------------------------------------------------------------
-- SAMPLE DATA
-----------------------------------------------------------------------

itemInvalidPriceData : ItemSummary.ItemSummaryDataRecord
itemInvalidPriceData =
  { name            = "chicken legs"
  , id              = "CHKCCS1233"
  , imageThumbnail  = "https://www.example.com/chicken.jpg"
  , brand           = "caribbean chicken"
  , variant         = "bag"
  , price           = "$15.93"
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
  , discount        = { discount_code = "UXDS9y3"
                      , name          = "seafood giveaway"
                      , value         = "15"
                      , iems          = ["CHKCCS1233"]
                      }
  }


-----------------------------------------------------------------------
-- TESTS
-----------------------------------------------------------------------

newItemSummary =
  describe "newItemSummary"
    [ it ( "produces InvalidItemData on \"price\" field on NaN " ++
            "price data" )
         (\_ ->
           Expect.equal
             (ItemSummary.newItemSummary itemInvalidPriceData)
             (Err
               <| ItemSummary.InvalidItemData itemInvalidPriceData.id
                                              "price")
         )
    ]
