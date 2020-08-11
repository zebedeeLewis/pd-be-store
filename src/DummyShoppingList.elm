module DummyShoppingList exposing (..)

import Random
import UUID

import ShoppingList
import DummyItem


-----------------------------------------------------------------------
-- CONSTANT DEFINITIONS
-----------------------------------------------------------------------



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

randomEntry : Int -> ShoppingList.Entry
randomEntry seed =
  let qty = DummyItem.randomInt 0 6 seed
      item = DummyItem.randomItemBrief seed
  in ShoppingList.newEntry qty item


randomList : Int -> ShoppingList.Model
randomList seed =
  let list = ShoppingList.empty 12
  in List.foldl
      (\i list_ ->
        let item = ShoppingList.item (randomEntry <| seed+i)
        in ShoppingList.add item list_
      ) list (List.range 1 20)
