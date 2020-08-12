module App exposing
  ( Model
  , Msg(..)
  , newItemBrowser
  , store
  , isItemBrowser
  , loadData
  , loadCart
  , update
  )

import Time
import Task

import UseCase


-----------------------------------------------------------------------
-- CONSTANT DEFINITIONS
-----------------------------------------------------------------------



-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

type Model
  = ItemBrowser UseCase.Store


type Msg
  = NoOp
  | CartLoaded Int
  | DataLoaded Int
  | RemoveItemFromCart String
  | AddItemToCart String
  | ProceedToCheckout UseCase.Store
  | ViewItemDetails String
  | Log String



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

newItemBrowser : Float -> Model
newItemBrowser tax =
  ItemBrowser (UseCase.startShopping tax)


update : Msg -> Model -> Model
update msg app =
  case msg of
    NoOp -> app

    CartLoaded cart_ -> 
      case app of
        ItemBrowser _ ->
          ItemBrowser (UseCase.dummyStore cart_)

    DataLoaded data ->
      case app of
        ItemBrowser _ ->
          ItemBrowser (UseCase.dummyStore data)

    RemoveItemFromCart itemId ->
      case app of
        ItemBrowser _ ->
          ItemBrowser (UseCase.removeItemFromCart itemId <| store app)

    AddItemToCart itemId ->
      case app of
        ItemBrowser _ ->
          case (UseCase.addItemToCart itemId <| store app) of
            Err _ -> ItemBrowser (store app)
            Ok store_ -> ItemBrowser store_
      
    ProceedToCheckout cart_ ->
      case app of
        ItemBrowser _ -> app

    ViewItemDetails itemId -> app

    Log _ -> app


loadCart : Model -> Cmd Msg
loadCart app =
  case app of
    ItemBrowser _ ->
      Task.perform
        (\pTime ->
          CartLoaded (Time.posixToMillis pTime)
        ) Time.now


loadData : Model -> Cmd Msg
loadData app =
  case app of
    ItemBrowser _ ->
      Task.perform
        (\pTime ->
          DataLoaded (Time.posixToMillis pTime)
        ) Time.now


store : Model -> UseCase.Store
store app = 
  case app of
    ItemBrowser store_ -> store_


isItemBrowser : Model -> Bool
isItemBrowser app =
  case app of
    ItemBrowser _ -> True


