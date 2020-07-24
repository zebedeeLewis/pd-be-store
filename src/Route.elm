module Route exposing
  ( Route(..)
  , Msg(..)
  , fromUrl
  )


import Url
import Url.Builder as Builder
import Url.Parser as Parser exposing (s, top, (</>))

import Logging



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

