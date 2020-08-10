module App exposing
  ( Model(..)
  , Msg(..)
  , newItemBrowser
  , loadData
  , loadCart
  , itemSet
  , cart
  , update
  )

import Time
import Task

import Item
import ShoppingList

-- TEST PURPOSES ONLY
import DummyItem
import DummyShoppingList



-----------------------------------------------------------------------
-- CONSTANT DEFINITIONS
-----------------------------------------------------------------------



-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

type Model
  = ItemBrowser ItemBrowserM


type ItemBrowserM = ItemBrowserM ShoppingList.Model Item.Set


type Msg
  = NoOp
  | CartLoaded Int
  | DataLoaded Int



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

newItemBrowser : Model
newItemBrowser =
  ItemBrowser <| ItemBrowserM ShoppingList.empty Item.emptySet


update : Msg -> Model -> Model
update msg model =
  case msg of
    NoOp -> model
    CartLoaded cart_ -> 
      case model of
        ItemBrowser _ ->
          ItemBrowser
            <| ItemBrowserM (DummyShoppingList.randomList cart_)
                            (itemSet model)

    DataLoaded data ->
      case model of
        ItemBrowser _ ->
          ItemBrowser
            <| ItemBrowserM (cart model)
                            (DummyItem.randomSet data)


loadCart : Model -> Cmd Msg
loadCart model =
  case model of
    ItemBrowser _ ->
      Task.perform
        (\pTime ->
          CartLoaded (Time.posixToMillis pTime)
        ) Time.now


loadData : Model -> Cmd Msg
loadData model =
  case model of
    ItemBrowser _ ->
      Task.perform
        (\pTime ->
          DataLoaded (Time.posixToMillis pTime)
        ) Time.now


itemSet : Model -> Item.Set
itemSet model =
  case model of
    ItemBrowser (ItemBrowserM _ itemSet_) -> itemSet_


cart : Model -> ShoppingList.Model
cart model =
  case model of
    ItemBrowser (ItemBrowserM cart_ _) -> cart_

