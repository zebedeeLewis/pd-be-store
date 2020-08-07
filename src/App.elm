module App exposing -- Test Exports, uncomment the exposing block below for
  -- testing.
  (..)
 
  -- Production Exports, uncomment the exposing block below for
  -- production and comment out the "Test Exports" above.
  -- (
  -- )

import Item
import ShoppingList


-----------------------------------------------------------------------
-- CONSTANT DEFINITIONS
-----------------------------------------------------------------------

emptyBrowser : Model
emptyBrowser = ItemBrowser ShoppingList.empty Item.emptySet



-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

type Model
  = Loading
  | ItemBrowser ShoppingList.ShoppingList Item.Set


type Msg = Loaded



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

{-| produce a new ItemBrowser application model
-}
newItemBrowser : ShoppingList.ShoppingList -> Item.Set -> Model
newItemBrowser cart items =
  ItemBrowser cart items


{-| update an application model according to the given message.
TODO!!!
-}
update : Msg -> Model -> Model
update msg app = app


{-| produce the title for the given Model
TODO!!!
-}
getTitle : Model -> String
getTitle appModel = "test"

