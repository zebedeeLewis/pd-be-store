module ShoppingList exposing
  ( Model
  , Entry
  , newEntry
  , remove
  , fromListOfItems
  , add
  , item
  , tax
  , entries
  , qty
  , empty
  , maybeEntry
  , randomList
  , randomEntry
  )


import Round
import Random
import SRandom
import UUID

import Item


-----------------------------------------------------------------------
-- CONSTANT DEFINITIONS
-----------------------------------------------------------------------



-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

{-| Represents a users shopping list.
-}
--                        tax    list-of-items
type Model = ShoppingList Float  (List Entry)


{-| Represents a single entry in a user shopping list. contains a
reference to an ItemSummary as well as the quantity of that item in
the list.

examples:
  
  briefData = 
    { name : "Chicken wings"
    , id : "CHID123"
    , brand : "Quality Fowls
    ...
    }

  item = Item.newSummary briefData

  --            QTY  Item
  entry = Entry 5    item
-}
type Entry = Entry Int Item.Model



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

fromListOfItems : Float -> List Item.Model -> Model
fromListOfItems tax_ loi =
  let list = empty tax_
  in List.foldl add list loi


newEntry : Int -> Item.Model -> Entry
newEntry qty_  item_ =
  Entry qty_ item_


{-| produce a new empty shopping list.
-}
empty : Float -> Model
empty tax_ = ShoppingList tax_ []


-- {-| poduce the total list price on the given shopping list.
-- -}
-- listTotal : Model -> Float
-- listTotal model =
--   Round.roundNum 2
--   <| List.foldl
--        (\entry_ acc ->
--          let listPrice = Item.listPrice (item entry_)
--              listTotal_ = ((toFloat <| qty entry_) * listPrice)
--          in acc + listTotal_
--        ) 0 (entries model)


-- saleTotal : Model -> Float
-- saleTotal model =
--   Round.roundNum 2
--   <| List.foldl
--        (\entry_ acc ->
--          let salePrice = Item.salePrice (item entry_)
--              saleTotal_ = ((toFloat <| qty entry_) * salePrice)
--          in acc + saleTotal_
--        ) 0 (entries model)


-- calcSavings : Model -> Float
-- calcSavings model =
--   (listTotal model) - (saleTotal model)


-- applyTaxTo : Float -> Model -> Float
-- applyTaxTo price list =
--   Round.roundNum 2 (price + (price * (tax list)/100))


-- taxedListTotal : Model -> Float
-- taxedListTotal list =
--   Round.roundNum 2 <| (listTotal list) * (tax list)/100


-- taxedSaleTotal : Model -> Float
-- taxedSaleTotal list =
--   Round.roundNum 2 <| (saleTotal list) * (tax list)/100


{-| remove the entry identified by the given id from the ShoppingList
if the quantity is 1. If the quantity is greater than 1, then decrement
the quantity by 1.
-}
remove : String -> Model -> Model
remove itemId list =
  let
    remove_ itemId_ =
      ShoppingList (tax list)
        <| List.filter
             (\entry_ ->
               not ((Item.id <| item entry_) == itemId_)
             ) (entries list)

    dec itemId_ =
      ShoppingList (tax list)
        <| List.map
          (\entry_ ->
            if (Item.id <| item entry_) == itemId_ 
              then Entry ((qty entry_) - 1) (item entry_)
              else Entry (qty entry_) (item entry_)
          ) (entries list)
  in
    case maybeEntry itemId list of
      Nothing -> list
      Just entry_ ->
        if (qty entry_) > 1
          then dec (Item.id <| item entry_)
          else remove_ (Item.id <| item entry_)


{-| produce a new ShoppingList with a new entry for the given item
-}
add : Item.Model -> Model -> Model
add item_ list =
  let
    itemId = Item.id item_
    add_ =
      ShoppingList (tax list) <| (singletonEntry item_)::(entries list)

    inc =
      ShoppingList (tax list)
        <| List.map
          (\entry_ ->
            if (Item.id <| item entry_) == itemId
              then Entry ((qty entry_) + 1) (item entry_)
              else Entry (qty entry_) (item entry_)
          ) (entries list)
  in
    case maybeEntry itemId list of
      Nothing ->
        add_
      Just _ ->
        inc


{-| produce the entry in the list with the given id or
Nothing
-}
maybeEntry : String -> Model -> Maybe Entry
maybeEntry itemId list =
  let
    maybeEntry_ entries_ = 
      case List.head entries_ of
        Nothing -> Nothing
        Just entry_ -> 
          if (Item.id <| item entry_) == itemId
            then Just entry_
            else maybeEntry_ <| List.drop 1 entries_
  in maybeEntry_ (entries list)


{-| produce a new shopping list entry representing one item.
-}
singletonEntry : Item.Model -> Entry
singletonEntry item_ = Entry 1 item_


{-| produce a list of all entries in the given list
-}
entries : Model -> List Entry
entries (ShoppingList _ entries_) = entries_


tax : Model -> Float
tax (ShoppingList tax_ _) = tax_


item : Entry -> Item.Model
item (Entry _ item_) = item_


qty : Entry -> Int
qty (Entry qty_  _) = qty_


-- Dummy Data

randomEntry : Int -> Entry
randomEntry seed =
  let qty_ = SRandom.randomInt 0 6 seed
      item_ = Item.produce_random_summary seed
  in newEntry qty_ item_


randomList : Int -> Model
randomList seed =
  let list = empty 12
  in List.foldl
      (\i list_ ->
        let item_ = item (randomEntry <| seed+i)
        in add item_ list_
      ) list (List.range 1 20)


