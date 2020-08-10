module ShoppingList exposing
 -- Test Exports, uncomment the exposing block below for
 -- testing.
 
 (..)

 -- Production Exports, uncomment the exposing block below for
 -- production and comment out the "Test Exports" above.
-- ( ShoppingList
-- , ItemTotalFn
-- , Entry
-- , total
-- , remove
-- , add
-- , empty
-- , maybeEntry
-- )


import Round

import Item



-----------------------------------------------------------------------
-- CONSTANT DEFINITIONS
-----------------------------------------------------------------------



-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

{-| Represents a users shopping list.
-}
type Model = ShoppingList (List Entry)


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

  item = Item.newBrief briefData

  --            QTY  Item
  entry = Entry 5    item
-}
type Entry = Entry Int Item.Model



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

{-| produce a new empty shopping list.
-}
empty : Model
empty = ShoppingList []


{-| poduce the subtotal on the given shopping list.
-}
subTotal : Model -> Float
subTotal (ShoppingList entries_) =
  Round.roundNum 2
  <| List.foldl
       (\entry_ acc ->
         let listPrice = Item.listPrice (item entry_)
             itemSubTotal = ((toFloat <| qty entry_) * listPrice)
         in acc + itemSubTotal
       ) 0 entries_


{-| remove the entry identified by the given id from the ShoppingList
if the quantity is 1. If the quantity is greater than 1, then decrement
the quantity by 1.
-}
remove : String -> Model -> Model
remove itemId list =
  let
    remove_ itemId_ (ShoppingList entries_) =
      ShoppingList
        <| List.filter
             (\entry_ ->
               not ((Item.id <| item entry_) == itemId_)
             ) entries_

    dec itemId_ (ShoppingList entries_) =
      ShoppingList
        <| List.map
          (\entry_ ->
            if (Item.id <| item entry_) == itemId_ 
              then Entry ((qty entry_) - 1) (item entry_)
              else Entry (qty entry_) (item entry_)
          ) entries_
  in
    case maybeEntry itemId list of
      Nothing -> list
      Just entry_ ->
        if (qty entry_) > 1
          then dec (Item.id <| item entry_) list
          else remove_ (Item.id <| item entry_) list


{-| produce a new ShoppingList with a new entry for the given item
-}
add : Item.Model -> Model -> Model
add item_ list =
  let
    itemId = Item.id item_
    addTo (ShoppingList entries_) =
      ShoppingList <| (singletonEntry item_)::entries_

    inc (ShoppingList entries_) =
      ShoppingList
        <| List.map
          (\entry_ ->
            if (Item.id <| item entry_) == itemId
              then Entry ((qty entry_) + 1) (item entry_)
              else Entry (qty entry_) (item entry_)
          ) entries_
  in
    case maybeEntry itemId list of
      Nothing ->
        addTo list
      Just _ ->
        inc list


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
entries (ShoppingList entries_) = entries_


item : Entry -> Item.Model
item (Entry _ item_) = item_


qty : Entry -> Int
qty (Entry qty_  _) = qty_


