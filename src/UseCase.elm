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

{-| Interface defines a function used to display a view of the contents
of a shopping list.
-}
ShoppingListView view =
  (List 
     { name       : String
     , brand      : String
     , variant    : String
     , size       : String
     , listTotal  : String
     , saleTotal  : String
     , qty        : String
     }
  ) -> view



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

{-| produce a view of the given item brief. The type of the view depends
on the return type of the ItemBriefView function.
-}
viewItemBrief
  : ( Item.BriefDataR -> view )
  -> Item.Model
  -> view
viewItemBrief viewFn item =
  viewFn <| Item.toData item


{-| produce a view of the contents of the given shopping list.
-}
viewListContent : ShoppingListView view -> ShoppingList.Model -> view
viewListContent renderer itemSet =
  renderer <| Item.setToData itemSet


