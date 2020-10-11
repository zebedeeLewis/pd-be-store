module Catalog exposing
  ( Model
  , Msg
  , View
  , Error(..)
  , PageNumber
  , CurrentPageNumber
  , PagesCount
  , NextPageNumber
  , Items
  , create_new_page
  , get_pages_count_from
  , goto_next_page
  , set_next_page_number_to
  , update
  , get_items_on
  , try_getting_item_with_id
  , random
  )

import Item
import SRandom



{-| represents a collection of items to be displayed to a user. A
Catalog simulates a set of pages and items in the pages.

-}
type Model = Page CurrentPageNumber PagesCount NextPageNumber Items

type alias PageNumber = Int
type alias CurrentPageNumber = PageNumber
type alias PagesCount = Int
type alias NextPageNumber = PageNumber
type alias Items = List Item.Model



get_pages_count_from : Model -> PagesCount
get_pages_count_from (Page _ pages_ _ _) = pages_



get_items_on : Model -> Items
get_items_on (Page _ _ _ items_) = items_



get_current_page_number_from : Model -> CurrentPageNumber
get_current_page_number_from (Page pageNumber _ _ items_) = pageNumber



get_next_page_number_from : Model -> NextPageNumber
get_next_page_number_from (Page _ _ pageNumber _) = pageNumber



try_getting_item_with_id : String -> Model -> Maybe Item.Model
try_getting_item_with_id subjectId currentPage =
  let items_with_subject_id =
        Item.get_id_of >> (==) subjectId
      produce_first_item_or_nothing = List.head
        
  in  get_items_on currentPage
        |> List.filter items_with_subject_id
        |> produce_first_item_or_nothing



set_next_page_number_to : NextPageNumber -> Model -> Model
set_next_page_number_to tentativeNextPageNumber page =
  let pagesCount = get_pages_count_from page
      items = get_items_on page
      currentPageNumber = get_current_page_number_from page
      nextPageNumber = 
        if tentativeNextPageNumber > pagesCount
          then pagesCount
          else tentativeNextPageNumber
  in Page currentPageNumber pagesCount nextPageNumber items



type Msg
  = SetNextPage NextPageNumber
  | GotoNextPage



update : Msg -> Model -> Model
update msg catalog =
  case msg of
    SetNextPage nextPageNumber ->
      catalog |> set_next_page_number_to nextPageNumber
    GotoNextPage -> catalog |> goto_next_page



goto_next_page : Model -> Model
goto_next_page page =
  let pagesCount = page |> get_pages_count_from
      items = page |> get_items_on
      currentPageNumber = page |> get_next_page_number_from
  in Page currentPageNumber pagesCount currentPageNumber items



create_new_page : CurrentPageNumber -> PagesCount -> Items -> Model
create_new_page tentativeCurrentPageNumber pagesCount items =
  let currentPageNumber =
        if tentativeCurrentPageNumber > pagesCount
          then pagesCount
          else tentativeCurrentPageNumber
  in Page currentPageNumber pagesCount currentPageNumber items



{-| Interface defines a function used to display a catalog page.
-}
type alias View view = CurrentPageNumber -> PagesCount -> Items -> view



show_page_using_view : View view -> Model -> view
show_page_using_view view currentPage =
  let pagesCount = get_pages_count_from currentPage
      items = get_items_on currentPage 
      currentPageNumber = get_next_page_number_from currentPage
  in view currentPageNumber pagesCount items



type Error = ItemNotInCatalog String



-- Dummy Data

random : Int -> Model
random seed =
  let loi = List.map
              (\i ->
                let seed_ = seed+i
                in Item.produce_random_item seed_
              ) <| List.range 1 30
      pageNumber = SRandom.randomInt 1 20 seed
  in create_new_page 20 pageNumber loi


