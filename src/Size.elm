module Size exposing
  ( Model
  , Error(..)
  , produce_mg_interpretation_of_float
  , produce_mm_interpretation_of_float
  , produce_cc_interpretation_of_float
  , produce_ml_interpretation_of_float
  , attempt_litre_convertion_of
  , parse
  , produce_litre_convertion_of_ml_value
  , stringify
  , produce_extra_small
  , produce_small
  , produce_medium
  , produce_large
  , produce_extra_large
  , produce_random_size
  , produce_random_size_string
  , produce_unknown
  , javascript_representation_of
  , decoder
  )

import Json.Encode as Encode
import Json.Decode as Decode
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
  | NA
  | Unknown



{-| TODO: refactor this function to make the compiler help us
should we add need to a new size constructor. As is right now, we need
to remember to add the new size here whenever we create a new size
constructor.-}
parse : String -> Model
parse strSize =
  case String.trim <| String.toLower strSize of 
    "large"  -> LG
    "lg"     -> LG
    "xl"     -> XL
    "xs"     -> XS
    "sm"     -> SM
    "m"      -> M
    "n/a"    -> NA
    measure  -> parse_measure_from_string measure



parse_measure_from_string : String -> Model
parse_measure_from_string size_string =
  let
    parse_float_from string =
      string |> String.toFloat

    firstWord =
      size_string
        |> String.words
        |> List.head
        |> Maybe.withDefault ""

    unit =
      case size_string of
        "ml" -> ML
        "mm" -> MM
        "cc" -> CC
        "mg" -> MG
        _    -> \_ -> Unknown

    secondWord = 
      size_string
        |> String.words
        |> (List.drop 1)
        |> List.head
        |> Maybe.withDefault ""

  in
    case parse_float_from firstWord of
      Nothing -> Unknown
      Just value -> unit value



stringify : Model -> String
stringify size =
  case size of
    ML value -> (String.fromFloat value) ++ " ml" 
    CC value -> (String.fromFloat value) ++ " cc"
    MG value -> (String.fromFloat value) ++ " mg"
    MM value -> (String.fromFloat value) ++ " mm"
    LG       -> "LG"
    XL       -> "XL"
    SM       -> "SM"
    XS       -> "XS"
    M        -> "M"
    NA       -> "N/A"
    Unknown  -> "unknown"



javascript_representation_of : Model -> Encode.Value
javascript_representation_of size =
  let sizeString = stringify size
  in Encode.string sizeString



json_encode : Model -> String
json_encode size =
  let value = javascript_representation_of size
  in Encode.encode 0 value



decoder : Decode.Decoder Model
decoder = Decode.map parse Decode.string



decode_json : String -> Result Decode.Error Model
decode_json jsonSize =
  Decode.decodeString decoder jsonSize



produce_ml_interpretation_of_float : Float -> Model
produce_ml_interpretation_of_float value = value |> ML



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



produce_mm_interpretation_of_float : Float -> Model
produce_mm_interpretation_of_float value = value |> MM



produce_mg_interpretation_of_float : Float -> Model
produce_mg_interpretation_of_float value = value |> MG



produce_cc_interpretation_of_float : Float -> Model
produce_cc_interpretation_of_float value = value |> CC



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



produce_unknown : Model
produce_unknown = Unknown



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
        1 -> produce_cc_interpretation_of_float randomFloat
        2 -> produce_mm_interpretation_of_float randomFloat
        3 -> produce_ml_interpretation_of_float randomFloat
        4 -> produce_mg_interpretation_of_float randomFloat
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

