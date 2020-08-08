module UseCase exposing
 -- Test Exports, uncomment the exposing block below for
 -- testing.
 -- (..)

 -- Production Exports, uncomment the exposing block below for
 -- production and comment out the "Test Exports" above.
  ( viewListContent
  )


import Item
import ShoppingList


-----------------------------------------------------------------------
-- CONSTANT DEFINITIONS
-----------------------------------------------------------------------



-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

{-| Interface defines a function used to display a view of the contents
of a shopping list.
-}
type alias ShoppingListView view =
  (List ShoppingEntryViewR) -> view


type alias ShoppingEntryViewR =
  { name       : String
  , brand      : String
  , variant    : String
  , size       : String
  , listTotal  : String
  , saleTotal  : String
  , qty        : String
  }



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
viewListContent renderer list =
  let entries = ShoppingList.entries list
      listViewData = 
        List.map entryToViewR entries
  in renderer listViewData


{-| produce a shopping list entry view record from the given Shopping
list entry.
-}
entryToViewR : ShoppingList.Entry -> ShoppingEntryViewR
entryToViewR entry =
  let item = ShoppingList.item entry
      qty = ShoppingList.qty entry
      listTotal = (toFloat qty) * (Item.listPrice item)
      saleTotal = (toFloat qty) * (Item.salePrice item)
  in
    { name       = Item.name item
    , brand      = Item.brand item 
    , variant    = Item.variant item
    , size       = Item.sizeToString <| Item.size item
    , listTotal  = String.fromFloat listTotal 
    , saleTotal  = String.fromFloat saleTotal
    , qty        = String.fromInt qty
    }
