module Route exposing
  ( Route(..)
  , Msg(..)
  , fromUrl
  , route
  )


import Url
import Url.Builder as Builder
import Url.Parser as Parser exposing (s, top, (</>))

import Logging
import View



-----------------------------------------------------------------------
-- CONSTANT DEFINITIONS
-----------------------------------------------------------------------



-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

{-|
  represents a route to an internal page.
-}
type Route
  = NotFound
  | SearchResults


{-|
  represents messages related to internal routing.
-}
type Msg
  = ChangeRoute Route
  | UrlChanged Url.Url
  | LogMessage Logging.LogLevel



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

{-|
  produce a route from the given url
-}
fromUrl : Url.Url -> Route
fromUrl url =
  let
    parsers =
      Parser.oneOf
        [ Parser.map NotFound (s "not_found")
        ]
  in
    -- Parser.oneOf produce Nothing of the url path is just "/"
    -- this workaround allows us to map "/" to SearchResults.
    if ((String.trim url.path) == "")
      then SearchResults
      else Maybe.withDefault NotFound (Parser.parse parsers url)


{-|
  produce the View that is mapped to the given Route.
-}
route : Route -> View.View
route r =
  case r of
    NotFound -> View.NotFound
    SearchResults -> View.SearchResults


{-|
  produce the url representation of the given route.
-}
toMaybeUrl : Route -> Maybe Url.Url
toMaybeUrl r =
  Url.fromString (toString r)


{-|
  produce a string representation of the given route.
-}
toString : Route -> String
toString r =
  Builder.absolute (toPieces r) []


{-|
  produce a list of path segments corresponding to the given
  route.
-}
toPieces : Route -> List String
toPieces r =
  case r of
    NotFound -> ["not_found"]
    SearchResults -> ["store"]
