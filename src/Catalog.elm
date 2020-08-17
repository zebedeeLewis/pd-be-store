module Catalog exposing
  ( Model
  , Msg
  , new
  , pages
  , gotoNextPage
  , setNextPage
  , update
  )

import Item


-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

{-| represents a collection of items to be displayed to a user. A
Catalog simulates a set of pages and items in the pages.
-}
type Model items = Catalog Pagination (List items)


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


type Msg items
  = SetNextPage Int
  | GotoNextPage


-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

update : Msg items -> Model items -> Model items
update msg catalog =
  case msg of
    SetNextPage page_ -> setNextPage page_ catalog
    GotoNextPage -> gotoNextPage catalog


{-| Get the number of pages in the Catalog.
-}
pages : Model items -> Int
pages (Catalog pagination_ _) = pagination_.pages


{-| Get the pagination element from the Catalog.
-}
pagination : Model items -> Pagination
pagination (Catalog pagination_ _) = pagination_


{-| Get the list of items from the Catalog. This list represents
whats in the current page.
-}
items : Model items -> List items
items (Catalog _ items_) = items_


{-| Set the page to be viewed on the next page jump.
-}
setNextPage : Int -> Model item -> Model item
setNextPage page_ catalog =
  let pages_ = catalog |> pages
      pagination_ = catalog |> pagination
      loi = catalog |> items
      nextPage_ = if page_ > pages_ then pages_ else page_
  in Catalog { pagination_ | nextPage = nextPage_ } loi


{-| Jump to the next page.
-}
gotoNextPage : Model item -> Model item
gotoNextPage (Catalog pagination_ loi) =
  Catalog { pagination_ | page = pagination_.nextPage } loi


{-| create a new catalog with the given information.
-}
new : Int -> Int -> List items -> Model items
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


