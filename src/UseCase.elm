module UseCase exposing
 -- Test Exports, uncomment the exposing block below for
 -- testing.
 -- (..)

 -- Production Exports, uncomment the exposing block below for
 -- production and comment out the "Test Exports" above.
  ( CartView
  , EntryViewR
  , removeOneCartItem
  , addOneCartItem
  , viewShoppingCart
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
type alias CartView view
  =  Float                 -- cartSaleSubTotal
  -> Float                 -- cartTaxPct
  -> Float                 -- cartTaxVal
  -> Float                 -- cartSaleTotal
  -> Float                 -- cartTotalSavings
  -> (List EntryViewR) -- cartEntries
  -> view


type alias EntryViewR =
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


-- {-| produce a view of the given item brief. The type of the view depends
-- on the return type of the ItemBriefView function.
-- -}
-- viewItemBrief
--   : ( Item.BriefDataR -> view )
--   -> Item.Model
--   -> view
-- viewItemBrief viewFn item =
--   viewFn <| Item.toData item


-- {-| produce a view of the contents of the given shopping list.
-- -}
-- viewListContent : ShoppingListView view -> ShoppingList.Model -> view
-- viewListContent renderer list =
--   let entries = ShoppingList.entries list
--       listViewData = 
--         List.map entryToViewR entries
--   in renderer listViewData


{-| produce a shopping list entry view record from the given Shopping
list entry.
-}
entryToViewR : ShoppingList.Entry -> EntryViewR
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


viewShoppingCart : CartView view -> ShoppingList.Model -> view
viewShoppingCart cartView cart =
  let taxPct = ShoppingList.tax cart
      subtotal unitPriceFn =
        Round.roundNum 2
          <| List.foldl
               (\entry acc ->
                 let unitPrice = unitPriceFn (ShoppingList.item entry)
                     subtotal_ =
                       (toFloat <| ShoppingList.qty entry)*unitPrice
                 in acc + subtotal_
               ) 0 (ShoppingList.entries cart)

      saleSubTotal = subtotal Item.salePrice
      saleTax = Round.roundNum 2 (saleSubTotal * taxPct/100)
      saleTotal = saleSubTotal + saleTax
      listSubTotal = subtotal Item.listPrice
      listTax = Round.roundNum 2 (listSubTotal * taxPct/100)
      listTotal = listSubTotal + listTax
      totalSavings = listTotal - saleTotal
      cartEntries =
        List.map entryToViewR (ShoppingList.entries cart)

  in cartView saleSubTotal
              taxPct
              saleTax
              saleTotal
              totalSavings
              cartEntries
