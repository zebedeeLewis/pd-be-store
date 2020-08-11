module UseCase exposing
 -- Test Exports, uncomment the exposing block below for
 -- testing.
 -- (..)

 -- Production Exports, uncomment the exposing block below for
 -- production and comment out the "Test Exports" above.
  ( CartView
  , EntryViewR
  , Error
  , startShopping
  , removeItemFromCart
  , addItemToCart
  , viewCart
  , dummyStore
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


--                 GST     ShoppingCart         Store Catalog
type Store = Store Float   ShoppingList.Model   Item.Set


type Error = ItemNotInCatalog String Store


{-| Interface defines a function used to display a view of the contents
of a shopping list.
-}
type alias CartView view
  =  Float                 -- cartSaleSubTotal
  -> Float                 -- cartTaxPct
  -> Float                 -- cartTaxVal
  -> Float                 -- cartSaleTotal
  -> Float                 -- cartTotalSavings
  -> (List EntryViewR)     -- cartEntries
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


startShopping : Float -> Store
startShopping gst =
  let cart = ShoppingList.empty gst 
      catalog = Item.emptySet
  in Store gst cart catalog


getCartFrom : Store -> ShoppingList.Model
getCartFrom (Store _ cart _) = cart


getCatalogFrom : Store -> Item.Set
getCatalogFrom (Store _ _ catalog) = catalog


getGstFrom : Store -> Float
getGstFrom (Store gst _ _) = gst


removeItemFromCart : String -> Store -> Store
removeItemFromCart itemId store =
  let cart = getCartFrom store
      catalog = getCatalogFrom store
  in Store (getGstFrom store) (ShoppingList.remove itemId cart) catalog


addItemToCart : String -> Store -> Result Error Store
addItemToCart itemId store =
  let cart = getCartFrom store
      catalog = getCatalogFrom store
      maybeItem = Item.querySetFor itemId catalog
  in
   case maybeItem of
     Nothing -> Err ItemNotInCatalog itemId store
     Just item ->
       Ok Store (getGstFrom store) (ShoppingList.add item cart) catalog


viewCart : CartView view -> Store -> view
viewCart cartView store =
  let cart = getCartFrom store
      taxPct = ShoppingList.tax cart
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


-- DUMMY DATA FOR TESTING

dummyStore : Store
dummyStore seed =
  Store (DummyItem.randomFloat 12 15 seed)
        (DummyShoppinList.randomList seed)
        (DummyItem.randomSet seed)


