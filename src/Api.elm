module Api exposing
  ( get_items_where
  )


import Api.Query as Query

-- QUERY represents a set of key/value pairs used to narrow down a request.
-- should be able to join multiple queries using logical operators QUERY



get_items_where : Query.Model -> Int
get_items_where query =
  Debug.todo "TODO!!!"
