module UseCase exposing
  ( Store
  , CartView
  , ItemViewD
  , EntryViewD
  , Error(..)
  , startShopping
  , removeItemFromCart
  , addItemToCart
  , viewCart
  , dummyStore
  , browseCatalog
  )


import Round

import Item
import ShoppingList

import SRandom



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
  -> (List EntryViewD)     -- cartEntries
  -> view


type alias CatalogView view
  = List ItemViewD -> view


type alias EntryViewD =
  { qty : Int 
  , item : ItemViewD
  , listTotal : Float
  , saleTotal : Float
  }


type alias ItemViewD =
  { id          : String
  , name        : String
  , brand       : String
  , variant     : String
  , size        : String
  , image       : String
  , listPrice   : Float
  , salePrice   : Float
  , discountPct : Int
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


browseCatalog : CatalogView view -> Store -> view
browseCatalog catalogView store =
  let catalog = getCatalogFrom store
      loi = Item.listFromSet catalog
      viewData = List.map itemToViewD loi
  in catalogView viewData


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
     Nothing -> Err (ItemNotInCatalog itemId store)
     Just item ->
       Ok <| Store (getGstFrom store)
                   (ShoppingList.add item cart)
                   catalog


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
        List.map entryToViewD (ShoppingList.entries cart)

  in cartView saleSubTotal
              taxPct
              saleTax
              saleTotal
              totalSavings
              cartEntries


{-| produce a shopping list entry view record from the given Shopping
list entry.
-}
entryToViewD : ShoppingList.Entry -> EntryViewD
entryToViewD entry =
  let item = ShoppingList.item entry
      qty = ShoppingList.qty entry
      listTotal = Round.roundNum 2
                    <| (toFloat qty) * (Item.listPrice item)
      saleTotal = Round.roundNum 2
                    <| (toFloat qty) * (Item.salePrice item)
  in
    { qty        = qty
    , listTotal  = listTotal
    , saleTotal  = saleTotal
    , item       = itemToViewD item
    }


itemToViewD : Item.Model -> ItemViewD
itemToViewD item =
  { id           = Item.id item
  , name         = Item.name item
  , brand        = Item.brand item 
  , variant      = Item.variant item
  , size         = Item.sizeToString <| Item.size item
  , image        = Item.image item
  , listPrice    = Item.listPrice item 
  , salePrice    = Item.salePrice item
  , discountPct  = Item.discountPct item
  }


-- DUMMY DATA FOR TESTING

dummyStore : Int -> Store
dummyStore seed =
  Store (SRandom.randomFloat2 12 15 seed)
        (ShoppingList.randomList seed)
        (Item.randomSet seed)


