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

deptTag = ItemSummary.newDeptTag "UID123" "whole foods"
deptTag2 = ItemSummary.newDeptTag "UID456" "foods"

catTag = ItemSummary.newCatTag "UIDC123" "meats"
catTag2 = ItemSummary.newCatTag "UIDC456" "vegan"
subCatTag = ItemSummary.newSubCatTag "UIDSC123" "poultry"
subCatTag2 = ItemSummary.newSubCatTag "UIDSC456" "organic"

searchTag = ItemSummary.newSearchTag "UIDS123" "chicken"

discount =
  ItemSummary.newItemDiscount "UXDS9y3" "seafood giveaway" 15.0 ["CHKCCS1233"]

itemSummary1 : ItemSummary.ItemSummaryRecord
itemSummary1 =
  { name            = "chicken legs"
  , id              = "CHKCCS1233"
  , imageThumbnail  = "https://www.example.com/chicken.jpg"
  , brand           = "caribbean chicken"
  , variant         = "bag"
  , price           = 15.93
  , size            = Grad 1000.5 MG
  , departmentTags  = [ deptTag
                      , deptTag2
                      ]
  , categoryTags    = [ catTag
                      , catTag2
                      ]
  , subCategoryTags = [ subCatTag
                      , subCatTag2
                      ]
  , searchTags      = [ searchTag ]
  , availability    = IN_STOCK
  , discount        = discount
  }

itemSummary2 : ItemSummary.ItemSummaryRecord
itemSummary2 =
  { name            = "chicken legs"
  , id              = "CHKCCS4567"
  , imageThumbnail  = "https://www.example.com/chicken.jpg"
  , brand           = "caribbean chicken"
  , variant         = "bag"
  , price           = 15.93
  , size            = Grad 1000.5 MG
  , departmentTags  = [ deptTag
                      , deptTag2
                      ]
  , categoryTags    = [ catTag
                      , catTag2
                      ]
  , subCategoryTags = [ subCatTag
                      , subCatTag2
                      ]
  , searchTags      = [ searchTag ]
  , availability    = IN_STOCK
  , discount        = discount
  }

itemSummary3 : ItemSummary.ItemSummaryRecord
itemSummary3 =
  { name            = "chicken legs"
  , id              = "CHKCCS4567"
  , imageThumbnail  = "https://www.example.com/chicken.jpg"
  , brand           = "caribbean chicken"
  , variant         = "bag"
  , price           = 15.93
  , size            = ItemSummary.Grad 1000.5 ItemSummary.MG
  , departmentTags  = [ deptTag
                      ]
  , categoryTags    = [ catTag
                      , catTag2
                      ]
  , subCategoryTags = [ subCatTag
                      , subCatTag2
                      ]
  , searchTags      = [ searchTag ]
  , availability    = ItemSummary.IN_STOCK
  , discount        = discount
  }


-----------------------------------------------------------------------
-- TESTS
-----------------------------------------------------------------------

filterByDepartment =
  describe "filterByDepartment"
    [ it ( "produces a list of all ItemSummaryRecord with the " ++
           "given department tag." )
         (\_ ->
           Expect.equal
         )
    ]
