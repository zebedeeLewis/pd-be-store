module Catalog exposing
  ( Model
  , Msg
  , new
  , pages
  , gotoNextPage
  , setNextPage
  , update
  , items
  , item
  , random
  )

import Item
import SRandom


-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

{-| represents a collection of items to be displayed to a user. A
Catalog simulates a set of pages and items in the pages.
-}
type Model = Catalog Pagination (List Item.Model)


{-| represents the pages in a Catalog.

**page:** page number of the page the user is viewing.
**pages:** total number of pages.
**
-}
type alias Pagination =
  { page         : Int
  , pages        : Int
  , nextPage     : Int
  }


type Msg
  = SetNextPage Int
  | GotoNextPage


-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

update : Msg -> Model -> Model
update msg catalog =
  case msg of
    SetNextPage page_ -> setNextPage page_ catalog
    GotoNextPage -> gotoNextPage catalog


{-| Get the number of pages in the Catalog.
-}
pages : Model -> Int
pages (Catalog pagination_ _) = pagination_.pages


{-| Get the pagination element from the Catalog.
-}
pagination : Model -> Pagination
pagination (Catalog pagination_ _) = pagination_


{-| Get the list of items from the Catalog. This list represents
whats in the current page.
-}
items : Model -> List Item.Model
items (Catalog _ items_) = items_


{-| Get a single item from the list with the given Id
-}
item : String -> Model -> Maybe Item.Model
item id catalog =
  let items_ loi =
        let head = List.head loi
        in case head of
             Nothing -> Nothing
             Just item_ ->
               if (item_ |> Item.id) == id
                 then Just item_
                 else items_ (List.drop 1 loi)
  in items_ (catalog |> items)



{-| Set the page to be viewed on the next page jump.
-}
setNextPage : Int -> Model -> Model
setNextPage page_ catalog =
  let pages_ = catalog |> pages
      pagination_ = catalog |> pagination
      loi = catalog |> items
      nextPage_ = if page_ > pages_ then pages_ else page_
  in Catalog { pagination_ | nextPage = nextPage_ } loi


{-| Jump to the next page.
-}
gotoNextPage : Model -> Model
gotoNextPage (Catalog pagination_ loi) =
  Catalog { pagination_ | page = pagination_.nextPage } loi


{-| create a new catalog with the given information.
-}
new : Int -> Int -> List Item.Model -> Model
new pages_ currentPage loi =
  let currentPage_ = if currentPage > pages_
                       then pages_
                       else currentPage
      pagination_ = 
        { page         = currentPage_
        , pages        = pages_
        , nextPage     = currentPage_
        }
  in Catalog pagination_ loi



-- Dummy Data

random : Int -> Model
random seed =
  let loi = List.map
              (\i ->
                let seed_ = seed+i
                in Item.randomItemSummary seed_
              ) <| List.range 1 30
      page_ = SRandom.randomInt 1 20 seed
  in new 20 page_ loi


