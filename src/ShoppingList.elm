module ShoppingList exposing
  ( Model
  , Entry
  , remove_one_item_with_id
  , new_shopping_list_with_items
  , insert_item
  , get_item_from_entry
  , get_entries_from
  , get_quantity_from_entry
  , empty
  , get_possible_entry_with_id
  , produce_random_list_from_seed
  , produce_random_entry_from_seed
  )


import Round
import Random
import SRandom
import UUID
import Dict

import Item



{-| Represents a users shopping list.
-}
type Model = ShoppingList (Dict.Dict Item.Id Entry)



empty : Model
empty = ShoppingList Dict.empty



new_shopping_list_with_items : List Item.Model -> Model
new_shopping_list_with_items items =
  List.foldl insert_item empty items



remove_entry_with_id : Item.Id -> Model -> Model
remove_entry_with_id subjectId list =
  get_entries_from list
       |> Dict.remove subjectId
       |> ShoppingList



insert_new_entry : Entry -> Model -> Model
insert_new_entry subjectEntry list =
  let subjectItem = get_item_from_entry subjectEntry
      subjectId = Item.get_id_of subjectItem
  in get_entries_from list
       |> Dict.insert subjectId subjectEntry
       |> ShoppingList



remove_one_item_with_id : Item.Id -> Model -> Model
remove_one_item_with_id subjectId list =
  let possibleSubjectEntry = 
        list |> get_possible_entry_with_id subjectId

      subjectQuantity =
        possibleSubjectEntry
          |> Maybe.andThen (get_quantity_from_entry >> Just)
          |> Maybe.withDefault 0

      decrease_quantity_by_one entry_ =
        list |> remove_entry_with_id subjectId
             |> insert_new_entry (subtract_one_from_entry entry_)

  in case possibleSubjectEntry of
       Nothing -> list
       Just subjectEntry ->
         if subjectQuantity > 1
           then subjectEntry |> decrease_quantity_by_one
           else list |> remove_entry_with_id subjectId



insert_item : Item.Model -> Model -> Model
insert_item subjectItem list =
  let subjectId = Item.get_id_of subjectItem
      newEntry = create_singleton_entry_from subjectItem

      increase_quantity_by_one entry_ =
        list |> remove_entry_with_id subjectId
             |> insert_new_entry (add_one_to_entry entry_)

      possibleSubjectEntry =
        list |> get_possible_entry_with_id subjectId

  in case possibleSubjectEntry of
       Nothing ->
         list |> insert_new_entry newEntry
       Just subjectEntry ->
         subjectEntry |> increase_quantity_by_one



get_entries_from : Model -> Dict.Dict Item.Id Entry
get_entries_from (ShoppingList entries_) = entries_



get_possible_entry_with_id : String -> Model -> Maybe Entry
get_possible_entry_with_id itemId list =
  get_entries_from list
       |> Dict.get itemId



{-| An entry gives us information on a single item in a shopping list
along with how many individual items of that class is in the list.
-}
type Entry = Entry Quantity Item.Model

type alias Quantity = Int



create_singleton_entry_from : Item.Model -> Entry
create_singleton_entry_from item_ = Entry 1 item_



set_entry_quantity_to : Quantity -> Entry -> Entry
set_entry_quantity_to quantity entry =
  let item = get_item_from_entry entry
  in Entry quantity item



subtract_one_from_entry : Entry -> Entry
subtract_one_from_entry entry =
  let currentQuantity = get_quantity_from_entry entry
  in entry |> set_entry_quantity_to (currentQuantity-1)



add_one_to_entry : Entry -> Entry
add_one_to_entry entry =
  let currentQuantity = get_quantity_from_entry entry
  in entry |> set_entry_quantity_to (currentQuantity+1)



get_item_from_entry : Entry -> Item.Model
get_item_from_entry (Entry _ item_) = item_



get_quantity_from_entry : Entry -> Int
get_quantity_from_entry (Entry qty_  _) = qty_



-- Dummy Data

produce_random_entry_from_seed : Int -> Entry
produce_random_entry_from_seed seed =
  let qty_ = SRandom.randomInt 0 6 seed
      item_ = Item.produce_random_item seed
  in create_singleton_entry_from item_
       |> set_entry_quantity_to qty_



produce_random_list_from_seed : Int -> Model
produce_random_list_from_seed seed =
  let list = empty
  in List.foldl
      (\i list_ ->
        let item_ = produce_random_entry_from_seed (seed+i)
                      |> get_item_from_entry
        in insert_item item_ list_
      ) list (List.range 1 20)


