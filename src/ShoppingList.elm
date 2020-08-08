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
-- , getMaybeEntry
-- )

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
subTotal (ShoppingList entries) =
  List.foldl
    (\entry acc ->
      let (Entry qty item) = entry
          itemSubtotal = Item.listPrice item
      in acc + ((toFloat qty) * itemSubtotal)
    ) 0 entries


{-| remove the entry identified by the given id from the ShoppingList
if the quantity is 1. If the quantity is greater than 1, then decrement
the quantity by 1.
-}
remove : String -> Model -> Model
remove itemId list =
  let
    remove_ itemId_ (ShoppingList entries) =
      ShoppingList
        <| List.filter
             (\(Entry qty item) -> not (Item.id item == itemId_))
             entries

    dec itemId_ (ShoppingList entries) =
      ShoppingList
        <| List.map
          (\(Entry qty item) ->
            if Item.id item == itemId_ 
              then Entry (qty - 1) item
              else Entry qty item
          ) entries
  in
    case getMaybeEntry itemId list of
      Nothing -> list
      Just (Entry qty item) ->
        if qty > 1
          then dec (Item.id item) list
          else remove_ (Item.id item) list


{-| produce a new ShoppingList with a new entry for the given item
-}
add : Item.Model -> Model -> Model
add item list =
  let
    itemId = Item.id item
    addTo (ShoppingList entries) =
      ShoppingList <| (singletonEntry item)::entries

    inc (ShoppingList entries) =
      ShoppingList
        <| List.map
          (\(Entry qty entryItem) ->
            if Item.id entryItem == itemId
              then Entry (qty + 1) entryItem
              else Entry qty entryItem)
          entries
  in
    case getMaybeEntry itemId list of
      Nothing ->
        addTo list
      Just _ ->
        inc list


{-| produce the entry in the list with the given id or
Nothing
-}
getMaybeEntry : String -> Model -> Maybe Entry
getMaybeEntry itemId (ShoppingList entries) =
  let
    getMaybeEntry_ entries_ = 
      case List.head entries_ of
        Nothing -> Nothing
        Just entry -> 
          let (Entry _ item) = entry
          in
            if Item.id item == itemId
              then Just entry
              else getMaybeEntry_ <| List.drop 1 entries
  in getMaybeEntry_ entries


{-| produce a new shopping list entry representing one item.
-}
singletonEntry : Item.Model -> Entry
singletonEntry item = Entry 1 item


