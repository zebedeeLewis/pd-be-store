module UseCase exposing
 -- Test Exports, uncomment the exposing block below for
 -- testing.
 (..)

 -- Production Exports, uncomment the exposing block below for
 -- production and comment out the "Test Exports" above.
 -- (..)

import Item


-----------------------------------------------------------------------
-- CONSTANT DEFINITIONS
-----------------------------------------------------------------------



-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

{-| produce a view of the given item brief. The type of the view depends
on the return type of the ItemBriefView function.
-}
viewItemBrief
  : ( Item.BriefDataR -> view )
  -> Item.Item
  -> view
viewItemBrief viewFn item =
  viewFn <| Item.toData item


{-| produce a view of the given set of items
-}
viewItemSet : (List Item.BriefDataR -> view) -> Item.Set -> view
viewItemSet renderer itemSet =
  renderer <| Item.setToData itemSet

