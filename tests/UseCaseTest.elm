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

itemBriefData : Item.BriefDataR
itemBriefData =
  { name            = "chicken legs"
  , id              = "CHKCCS1233"
  , imageThumbnail  = "https://www.example.com/chicken.jpg"
  , brand           = "caribbean chicken"
  , variant         = "bag"
  , price           = "15.93"
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


itemBrief : Item.Item
itemBrief =
  case Item.new itemBriefData of
    Err _ -> Item.blankBrief
    Ok brief -> brief



-------------------------------------------------------------------------
-- TESTS
-------------------------------------------------------------------------

viewItem =
  describe "viewItemBrief"
    [ todo "User should be able to view a single item brief"
    , it ("calls the given view function with the given item data " ++
          "and produce the results of the view function.")
        (\_ ->
          let viewFn item_ =
                [ item_.id
                , item_.imageThumbnail
                , String.join
                    " "
                    [item_.brand, item_.name, item_.variant]
                , item_.size
                , item_.price
                , item_.availability
                ]

              expected = 
                [ "CHKCCS1233"
                , "https://www.example.com/chicken.jpg"
                , "caribbean chicken chicken legs bag"
                , "1000.5 mg"
                , "15.93"
                , "in_stock"
                ]

              actual = UseCase.viewItemBrief viewFn itemBrief
          in
            Expect.equal expected actual
        )
    ]



viewItemSet = todo "User should be able to view a set of item briefs"

viewFilters = todo ("User should be able to view all available " ++
                    "filters for the item set in view.")

viewSortOpts = todo ("User should be able to view all sorting " ++
                     "options available for the item set in view.")

filterSet = todo ("User should be able to filter an item set " ++
                  "by one or more qualifiers.")

sortSet = todo ("User should be able to sort an item set by one " ++
                "or more qualifiers.")

viewCategorizedSet = todo ("user should be able to view a " ++
                           "categorized set of items briefs.")

viewShoppingCart = todo "User should be able to view a shopping cart"

addToCart = todo "User should be able to add item to cart"

removeFromCart = todo "User should be able to remove item from cart"

viewCartTotal = todo "User should be able to view cart total"

viewCartSubtotal = todo "User should be able to view cart subtotal"

viewDiscounts = todo "User should be a ble to view applied discounts"


