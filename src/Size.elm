module Size exposing
  ( Model
  , Error(..)
  , parse_mg_from_float
  , parse_mm_from_float
  , parse_cc_from_float
  , parse_ml_from_float
  , attempt_litre_convertion_of
  , parse_string
  , produce_litre_convertion_of_ml_value
  , stringify
  , produce_extra_small
  , produce_small
  , produce_medium
  , produce_large
  , produce_extra_large
  , produce_random_size
  , produce_random_size_string
  )

import Random
import SRandom



{-| An items size can be represented with an exact measurement such as
"20 mg", or a generic estimate such as LG, XL etc.

We need to ristrict the units we support so that we can make our
interface a lot simpler to reason about. So we only support one unit
of measurment each for length, volume, liquid volume, and weight.

examples:

  size1 : Size
  size1 = LG
  
  size2 : Size
  size2 = XL
  
  size4 : Size
  size4 = ML 2.5

  size4 : Size
  size4 = 3.5 |> MM
-}
type Model
  = ML Float
  | MM Float
  | CC Float
  | MG Float
  | XS
  | SM
  | M
  | LG
  | XL



parse_string : String -> Result Error Model
parse_string strSize =
  case String.trim <| String.toLower strSize of 
    "large"  -> Ok LG
    "lg"     -> Ok LG
    "xl"     -> Ok XL
    "xs"     -> Ok XS
    "sm"     -> Ok SM
    "m"      -> Ok M
    measure  -> parse_measure_from_string measure



parse_measure_from_string : String -> Result Error Model
parse_measure_from_string size_string =
  let
    attempt_to_interpret_float_from possiblyFloat =
      possiblyFloat |> String.toFloat

    first_word_in size_string_ =
      size_string_ |> String.words >> List.head >> Maybe.withDefault ""

    attempt_to_interpret_unit_from possiblyUnit =
      case possiblyUnit of
        "ml" -> Just ML
        "mm" -> Just MM
        "cc" -> Just CC
        "mg" -> Just MG
        _    -> Nothing

    second_word_in size_string_ = 
      size_string_
        |> String.words
        |> (List.drop 1)
        |> List.head
        |> Maybe.withDefault ""

    error_message = convertion_error_message size_string "size"
  in
    case attempt_to_interpret_float_from (first_word_in size_string) of
      Nothing -> Err (ConvertionError error_message)
      Just value ->
        case attempt_to_interpret_unit_from
               (second_word_in size_string) of
          Nothing -> Err (ConvertionError error_message)
          Just unit ->
            Ok (unit value)



parse_ml_from_float : Float -> Model
parse_ml_from_float value = value |> ML



one_litre_as_ml = 1000



attempt_litre_convertion_of : Model -> Result Error Float
attempt_litre_convertion_of size =
  case size of
    ML mlValue -> Ok <| one_litre_as_ml/mlValue
    _ ->
      let error_message =
            convertion_error_message
              (stringify size)
              "litre"
      in Err <| ConvertionError error_message



produce_litre_convertion_of_ml_value : Float -> Float
produce_litre_convertion_of_ml_value mlValue =
  one_litre_as_ml * mlValue



parse_mm_from_float : Float -> Model
parse_mm_from_float value = value |> MM



parse_mg_from_float : Float -> Model
parse_mg_from_float value = value |> MG



parse_cc_from_float : Float -> Model
parse_cc_from_float value = value |> CC



produce_extra_small : Model
produce_extra_small = XS



produce_small : Model
produce_small = SM



produce_medium : Model
produce_medium = M



produce_large : Model
produce_large = LG



produce_extra_large : Model
produce_extra_large = XL



stringify : Model -> String
stringify size =
  case size of
    ML value -> (String.fromFloat value) ++ " ml" 
    CC value -> (String.fromFloat value) ++ " cc"
    MG value -> (String.fromFloat value) ++ " mg"
    MM value -> (String.fromFloat value) ++ " mm"
    LG -> "LG"
    XL -> "XL"
    SM -> "SM"
    XS -> "XS"
    M  -> "M"




type Error
  = ConvertionError String



convertion_error_message : String -> String -> String
convertion_error_message from_size to_size =
  let from_size_ = String.trim from_size
      to_size_ = String.trim to_size
  in ("It doesn't make sense for me to convert from " ++ from_size_
     ++ " to " ++ to_size_ ++ ".")


-- DUMMY DATA

produce_random_size : Int -> Model
produce_random_size seed =
  let
    randomFloat = (SRandom.randomFloat2 1.0 1000.00 seed)
    mapper random  =
      case random of
        1 -> parse_cc_from_float randomFloat
        2 -> parse_mm_from_float randomFloat
        3 -> parse_ml_from_float randomFloat
        4 -> parse_mg_from_float randomFloat
        5 -> produce_large
        6 -> produce_extra_large
        7 -> produce_small
        8 -> produce_extra_small
        _ -> produce_medium
    generator = Random.map mapper (Random.int 1 9)
  in Random.step generator (Random.initialSeed seed) |> Tuple.first



produce_random_size_string : Int -> String
produce_random_size_string seed =
  let randomSize = produce_random_size seed
  in stringify randomSize

