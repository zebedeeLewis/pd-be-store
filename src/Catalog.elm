module Catalog exposing
  ( Model
  , Msg
  , Error(..)
  , View
  , generate_new_page
  , produce_pages_count
  , goto_next_page
  , set_next_page_number_to
  , update
  , produce_page_items
  , produce_item_with_id
  , random
  )

import Item
import SRandom


-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

{-| represents a collection of items to be displayed to a user. A
Catalog simulates a set of pages and items in the pages.

example: 
  currentPageNumber = 1
  totalPages = 20
  nextPage = currentPageNumber + 1
  items = [ <item1>, <item2>, <item3> ... ]
  newCatalog = Page currentPageNumber totalPages nextPage items
-}
type Model = Page Int Int Int (List Item.Model)


type Msg
  = SetNextPage Int
  | GotoNextPage


{-| Interface defines a function used to display a catalog.
arguments are as follows:

**page:** current page number
**pages:** total number of pages
**items:** list of items on the page

example:
  viewCatalog : Catalog.View
  viewCatalog page pages items =
    div
      []
      [...]
-}
type alias View view = Int -> Int -> (List Item.Model) -> view


type Error = ItemNotInCatalog String


-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

update : Msg -> Model -> Model
update msg catalog =
  case msg of
    SetNextPage page_ -> set_next_page_number_to page_ catalog
    GotoNextPage -> goto_next_page catalog


produce_pages_count : Model -> Int
produce_pages_count (Page _ pages_ _ _) = pages_


produce_page_items : Model -> List Item.Model
produce_page_items (Page _ _ _ items_) = items_


produce_current_page_number : Model -> Int
produce_current_page_number (Page pageNumber _ _ items_) = pageNumber


produce_next_page_number : Model -> Int
produce_next_page_number (Page _ _ pageNumber _) = pageNumber


produce_item_with_id : String -> Model -> Maybe Item.Model
produce_item_with_id id catalog =
  let produce_item_with_id_ items =
        let head = List.head items
        in case head of
             Nothing -> Nothing
             Just item_ ->
               if (Item.get_id_of item_) == id
                 then Just item_
                 else produce_item_with_id_ (List.drop 1 items)
  in produce_item_with_id_ (catalog |> produce_page_items)


set_next_page_number_to : Int -> Model -> Model
set_next_page_number_to nextPageNumber page =
  let pagesCount = page |> produce_pages_count
      items = page |> produce_page_items
      currentPageNumber = page |> produce_current_page_number
      nextPageNumber_ = 
        if nextPageNumber > pagesCount
          then pagesCount
          else nextPageNumber
  in Page currentPageNumber pagesCount nextPageNumber_ items


goto_next_page : Model -> Model
goto_next_page page =
  let pagesCount = page |> produce_pages_count
      items = page |> produce_page_items
      currentPageNumber = page |> produce_next_page_number
  in Page currentPageNumber pagesCount currentPageNumber items


generate_new_page : Int -> Int -> List Item.Model -> Model
generate_new_page currentPageNumber pagesCount items =
  let currentPage_ = if currentPageNumber > pagesCount
                       then pagesCount
                       else currentPageNumber
  in Page currentPageNumber pagesCount currentPageNumber items


show_page_using_view : View view -> Model -> view
show_page_using_view view page =
  let pagesCount = page |> produce_pages_count
      items = page |> produce_page_items
      currentPageNumber = page |> produce_next_page_number
  in view currentPageNumber pagesCount items


-- Dummy Data

random : Int -> Model
random seed =
  let loi = List.map
              (\i ->
                let seed_ = seed+i
                in Item.produce_random_item seed_
              ) <| List.range 1 30
      pageNumber = SRandom.randomInt 1 20 seed
  in generate_new_page 20 pageNumber loi


