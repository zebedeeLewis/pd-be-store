module RouteTest exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import Url

import Route


-----------------------------------------------------------------------
-- EXAMPLE DATA
-----------------------------------------------------------------------

unknownUrl =
    { protocol = Url.Http
    , host = "www.example.com"
    , port_ = Just 8000
    , path = "/gobbledeegook"
    , query = Nothing
    , fragment = Nothing
    }

notFoundUrl =
    { protocol = Url.Http
    , host = "www.example.com"
    , port_ = Just 8000
    , path = "/not_found"
    , query = Nothing
    , fragment = Nothing
    }

rootUrl =
    { protocol = Url.Http
    , host = "www.example.com"
    , port_ = Just 8000
    , path = " "
    , query = Nothing
    , fragment = Nothing
    }


-----------------------------------------------------------------------
-- TESTS
-----------------------------------------------------------------------


fromUrl = describe "fromUrl"
    [ test "Should produce NotFound for unfamiliar url"
        (\_ -> (Expect.equal Route.NotFound (Route.fromUrl unknownUrl)))
    , test "Should produce NotFound for url with path \"not_found\""
        (\_ ->
          (Expect.equal Route.NotFound (Route.fromUrl notFoundUrl))
        )
    , test "Should produce SearchResults for path /"
        (\_ ->
          (Expect.equal Route.SearchResults (Route.fromUrl rootUrl))
        )
    ]
