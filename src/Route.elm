module Route exposing
  ( Model
  , parse_route_from
  , produce_string_from
  , produce_label_for
  , produce_route_to_search_results_page
  )


import Url
import Url.Builder as Builder
import Url.Parser as Parser exposing (s, top, (</>))
import Html exposing (Html)
import Browser
import Command



type Model
  = NotFound
  | SearchResults



produce_route_to_search_results_page : Model
produce_route_to_search_results_page = SearchResults



parse_route_from : Url.Url -> Model
parse_route_from url =
  let parsers = Parser.oneOf [ Parser.map NotFound (s "not_found") ]
  in
    -- Parser.oneOf produce Nothing if the url path is just "/"
    -- this workaround allows us to map "/" to SearchResults.
    if ((String.trim url.path) == "/")
      then SearchResults
      else Maybe.withDefault NotFound (Parser.parse parsers url)



produce_possible_url_from : Model -> Maybe Url.Url
produce_possible_url_from r = Url.fromString (produce_string_from r)



produce_string_from : Model -> String
produce_string_from route =
  Builder.absolute (produce_list_of_pieces_from route) []



produce_list_of_pieces_from : Model -> List String
produce_list_of_pieces_from route =
  case route of
    NotFound -> ["not_found"]
    SearchResults -> ["/"]



produce_label_for : Model -> String
produce_label_for route =
  case route of
    NotFound -> "Page Not Found"
    SearchResults -> "Home"



