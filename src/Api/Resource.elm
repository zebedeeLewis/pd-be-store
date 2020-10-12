module Api.Query exposing
  ( Model
  , page_number_equals
  )


import Catalog



-- QUERY represents a set of key/value pairs used to narrow down a request.
-- should be able to join multiple queries using logical operators QUERY
type Model = Query



page_number_equals : Catalog.PageNumber -> Model
page_number_equals pageNumber =
  Debug.todo "TODO!!!"

