module UseCase exposing
 -- Test Exports, uncomment the exposing block below for
 -- testing.
 -- (..)

 -- Production Exports, uncomment the exposing block below for
 -- production and comment out the "Test Exports" above.
  ( ShoppingListView
  , CartEntryViewR
  , viewListContent
  , removeOneCartItem
  , addOneCartItem
  )


import Round

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
  (List CartEntryViewR) -> view


type alias CartEntryViewR =
  { id         : String
  , name       : String
  , brand      : String
  , variant    : String
  , size       : String
  , image      : String
  , listTotal  : Float
  , saleTotal  : Float
  , qty        : Int
  }



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

removeOneCartItem : String -> ShoppingList.Model -> ShoppingList.Model
removeOneCartItem itemId cart = ShoppingList.remove itemId cart


addOneCartItem : String -> ShoppingList.Model -> ShoppingList.Model
addOneCartItem itemId cart =
  let maybeEntry = ShoppingList.maybeEntry itemId cart
  in
   case maybeEntry of
     Nothing -> cart
     Just entry ->
       ShoppingList.add (ShoppingList.item entry) cart


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
entryToViewR : ShoppingList.Entry -> CartEntryViewR
entryToViewR entry =
  let item = ShoppingList.item entry
      qty = ShoppingList.qty entry
      listTotal = Round.roundNum 2
                    <| (toFloat qty) * (Item.listPrice item)
      saleTotal = Round.roundNum 2
                    <| (toFloat qty) * (Item.salePrice item)
  in
    { id         = Item.id item
    , name       = Item.name item
    , brand      = Item.brand item 
    , variant    = Item.variant item
    , size       = Item.sizeToString <| Item.size item
    , image      = Item.image item
    , listTotal  = listTotal 
    , saleTotal  = saleTotal
    , qty        = qty
    }


