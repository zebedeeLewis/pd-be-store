module ShoppingList exposing (..)


-----------------------------------------------------------------------
-- CONSTANT DEFINITIONS
-----------------------------------------------------------------------



-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

{-| Represents a users shopping list.
-}
type ShoppingList = ShoppingList (List Entry)


{-| Represents a single entry in a user shopping list. contains a
reference to an ItemSummary as well as the quantity of that item in
the list and the final unit price. The final unit price is the price
of the item minus itemdiscount if any exists.

examples:
  
  Import ItemSummary

  --            QTY   final price  Item Id
  entry = Entry 5     5.50         "IDI73M"
-}
type Entry = Entry Int Float String



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

{-| produce a new empty shopping list.
-}
empty : ShoppingList
empty = ShoppingList []


{-| produce a new ShoppingList with the entry identified by the given
id removed.
TODO!!!
-}
remove : String -> Float -> ShoppingList -> ShoppingList
remove itemId itemPrice list =
  let
    remove_ itemId_ (ShoppingList entries) =
      ShoppingList
        <| List.filter
             (\(Entry qty price id) -> not (id == itemId_))
             entries

    dec itemId_ itemPrice_ (ShoppingList entries) =
      ShoppingList
        <| List.map
          (\(Entry qty price entryId) ->
            if entryId == itemId_ 
              then Entry (qty - 1) itemPrice_ itemId_
              else Entry qty price entryId)
          entries
  in
    case getMaybeEntry itemId list of
      Nothing -> list
      Just (Entry qty _ id) ->
        if qty > 1
          then dec itemId itemPrice list
          else remove_ itemId list



{-| produce a new ShoppingList with a new entry for the given item

Assumptions: we assume that an item with the given id exists somewhere
-}
add : String -> Float -> ShoppingList -> ShoppingList
add itemId itemPrice list =
  let
    add_ itemId_ itemPrice_ (ShoppingList entries) =
      ShoppingList <| (singletonEntry itemId_ itemPrice_)::entries

    inc itemId_ itemPrice_ (ShoppingList entries) =
      ShoppingList
        <| List.map
          (\(Entry qty price entryId) ->
            if entryId == itemId_ 
              then Entry (qty + 1) itemPrice_ itemId_
              else Entry qty price entryId)
          entries
  in
    case getMaybeEntry itemId list of
      Nothing ->
        add_ itemId itemPrice list
      Just (Entry _ _ id) ->
        inc itemId itemPrice list


{-| produce the entry in the list with the given id or
Nothing
-}
getMaybeEntry : String -> ShoppingList -> Maybe Entry
getMaybeEntry itemId (ShoppingList entries) =
  let
    getMaybeEntry_ entries_ = 
      case List.head entries_ of
        Nothing -> Nothing
        Just entry -> 
          let (Entry _ _ entryId) = entry
          in
            if entryId == itemId
              then Just entry
              else getMaybeEntry_ <| List.drop 1 entries
  in getMaybeEntry_ entries


{-| produce a new shopping list entry representing one item.
-}
singletonEntry : String -> Float -> Entry
singletonEntry itemId price = Entry 1 price itemId


