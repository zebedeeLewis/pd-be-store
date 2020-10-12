module Api.Endpoint exposing
  ( Model
  , string_representation_of
  )



import Item



{-| An endpoint represents a resource we want to retrieve from the
server. Each representation of the resource should have its own
endpoint.
-}
type Model
  = Items
  | ItemsAsArray
  | ItemsAsObject
  | Item Item.Id



type alias ItemId = Int



string_representation_of : Model -> String
string_representation_of endpoint =
  let apiBase = "/api/"
  in case endpoint of
       Items ->
         apiBase ++ "items/"

       ItemsAsArray ->
         apiBase ++ "array/items/"

       ItemsAsObject ->
         apiBase ++ "object/items/"

       Item itemId ->
         apiBase ++ "items/" ++ itemId ++ "/"


