module UseCase exposing
  ( Store
  , CartView
  , ItemViewD
  , EntryViewD
  , startShopping
  , removeItemFromCart
  , addItemToCart
  , viewCart
  , dummyStore
  , browseCatalog
  )


import Round

import Item
import Size
import Catalog
import ShoppingList

import SRandom


-----------------------------------------------------------------------
-- CONSTANT DEFINITIONS
-----------------------------------------------------------------------



-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

{-| represents a single shopping activity.

example:
  --           GST(%) Shopping Cart        Catalog
  shop = Store 12.5   ShoppingList.Model   (Catalog.Model)
-}
type Store = Store Float ShoppingList.Model (Catalog.Model)


{-| Interface defines a function used to display the contents of a
shopping list. The arguments are as follows:

**subtotal:** sum of all items in cart after applying discounts
but before applying tax.
**taxPct:** gst percentage
**tax:** value of gst applied
**total:** total cost of items in cart after applying discounts
and taxes.
**savints:** total saved on discounts.
**entries:** list of items in the cart.

example:
  viewCart : UseCase.cartView
  viewCart subtotal tax taxVal total savings entries =
    div
      []
      [...]
-}
type alias CartView view
  =  Float                 -- subtotal
  -> Float                 -- taxPct
  -> Float                 -- tax
  -> Float                 -- total
  -> Float                 -- savings
  -> (List EntryViewD)     -- entries
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
      catalog = Catalog.generate_new_page 1 20 []
  in Store gst cart catalog


getCartFrom : Store -> ShoppingList.Model
getCartFrom (Store _ cart _) = cart


getCatalogFrom : Store -> Catalog.Model
getCatalogFrom (Store _ _ catalog) = catalog


getGstFrom : Store -> Float
getGstFrom (Store gst _ _) = gst


browseCatalog : CatalogView view -> Store -> view
browseCatalog catalogView store =
  let catalog = getCatalogFrom store
      loi = Catalog.produce_page_items catalog
      viewData = List.map itemToViewD loi
  in catalogView viewData


removeItemFromCart : String -> Store -> Store
removeItemFromCart itemId store =
  let cart = getCartFrom store
      catalog = getCatalogFrom store
  in Store (getGstFrom store) (ShoppingList.remove itemId cart) catalog


addItemToCart : String -> Store -> Result Catalog.Error Store
addItemToCart itemId store =
  let cart = getCartFrom store
      maybeItem =
        getCatalogFrom store |> Catalog.produce_item_with_id itemId
  in
   case maybeItem of
     Nothing -> Err (Catalog.ItemNotInCatalog itemId)
     Just item ->
       Ok <| Store (getGstFrom store)
                   (ShoppingList.add item cart)
                   (getCatalogFrom store)


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

      saleSubTotal = 1000.00 -- subtotal Item.salePrice
      saleTax = Round.roundNum 2 (saleSubTotal * taxPct/100)
      saleTotal = saleSubTotal + saleTax
      listSubTotal = 2000.00 -- subtotal Item.listPrice
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
                    <| (toFloat qty) * (item |> Item.get_list_price_of)
      saleTotal = Round.roundNum 2
                    <| (toFloat qty) * (item |> Item.get_sale_price_of)
  in
    { qty        = qty
    , listTotal  = listTotal
    , saleTotal  = saleTotal
    , item       = itemToViewD item
    }


itemToViewD : Item.Model -> ItemViewD
itemToViewD item =
  let itemSize = Item.get_size_of item
  in { id           = Item.get_id_of item
     , name         = Item.get_name_of item
     , brand        = Item.get_brand_of item
     , variant      = Item.get_variant_of item
     , size         = Size.stringify itemSize
     , image        = Item.get_thumbnail_url_of item
     , listPrice    = Item.get_list_price_of item
     , salePrice    = Item.get_sale_price_of item
     , discountPct  = Item.get_discount_percentage_on item
     }


-- DUMMY DATA FOR TESTING

dummyStore : Int -> Store
dummyStore seed =
  Store (SRandom.randomFloat2 12 15 seed)
        (ShoppingList.randomList seed)
        (Catalog.random seed)


