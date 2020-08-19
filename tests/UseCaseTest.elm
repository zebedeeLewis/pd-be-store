module UseCaseTest exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)

import Item
import UseCase


-------------------------------------------------------------------------
-- SAMPLE DATA
-------------------------------------------------------------------------

it = test



-------------------------------------------------------------------------
-- SAMPLE DATA
-------------------------------------------------------------------------

itemSummaryData : Item.Data
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
                           , value         = "15.0"
                           , items         = ["CHKCCS1233"]
                           }
  }


itemSummary : Item.Model
itemSummary =
  case Item.produce_new_summary_from_data itemSummaryData of
    Err _ -> Item.blankSummary
    Ok brief -> brief


-------------------------------------------------------------------------
-- TESTS
-------------------------------------------------------------------------

viewCart =
  describe "User should be able to view contents of shopping list"
    [ todo ""
    ]


