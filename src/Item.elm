module Item exposing
  ( Model
  , get_id_of
  , get_name_of
  , get_thumbnail_url_of
  , get_size_of
  , get_variant_of
  , get_list_price_of
  , get_sale_price_of
  , get_discount_percentage_on
  , get_brand_of
  , produce_random_item
  )

import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Time
import Round
import Random
import SRandom
import UUID
import Size
import Discount
import Availability
import Tag



{-| represents a summary descriptions of a single type of inventory
item.
-}
type Model = Class Record

type alias Record =
  { name            : String
  , id              : String
  , imageThumbnail  : String
  , brand           : String
  , variant         : String
  , listPrice       : Float
  , size            : Size.Model
  , tags            : List Tag.Model
  , availability    : Availability.Model
  , discount        : Maybe Discount.Model
  }



javascript_representation_of : Model -> Encode.Value
javascript_representation_of item = 
  let name             = get_name_of item
      id               = get_id_of item
      imageThumbnail   = get_thumbnail_url_of item
      brand            = get_brand_of item
      variant          = get_variant_of item
      listPrice        = get_list_price_of item
      size             = get_size_of item
      tags             = get_tags_on item
      availability     = get_availability_of item
      possibleDiscount = get_possible_discount_on item
      discountValue  =
        case possibleDiscount of
          Nothing -> Encode.null
          Just discount ->
            Discount.javascript_representation_of discount

  in Encode.object
       [ ( "name", Encode.string name)
       , ( "id", Encode.string id )
       , ( "thumbnail_url", Encode.string imageThumbnail )
       , ( "brand", Encode.string brand )
       , ( "variant", Encode.string variant )
       , ( "list_price", Encode.float listPrice )
       , ( "size", Size.javascript_representation_of size )
       , ( "tags", Encode.list Tag.javascript_representation_of tags )
       , ( "availability"
         , Availability.javascript_representation_of availability
         )
       , ( "discount", discountValue )
       ]



json_encode : Model -> String
json_encode item =
  let value = javascript_representation_of item
  in Encode.encode 0 value



record_decoder : Decode.Decoder Record
record_decoder =
  Decode.succeed Record
    |> Pipeline.required "name" Decode.string
    |> Pipeline.required "id" Decode.string
    |> Pipeline.required "thumbnail_url" Decode.string
    |> Pipeline.required "brand" Decode.string
    |> Pipeline.required "variant" Decode.string
    |> Pipeline.required "list_price" Decode.float
    |> Pipeline.required "size" Size.decoder
    |> Pipeline.required "tags" (Decode.list Tag.decoder)
    |> Pipeline.required "availability" Availability.decoder
    |> Pipeline.required "discount" (Decode.maybe Discount.decoder)



decoder : Decode.Decoder Model
decoder =
  Decode.map Class record_decoder



decode_json : String -> Result Decode.Error Model
decode_json jsonItem =
  Decode.decodeString decoder jsonItem



blankClass : Model
blankClass =
  Class
    { name            = ""
    , id              = ""
    , imageThumbnail  = ""
    , brand           = ""
    , variant         = ""
    , listPrice       = 0.0
    , size            = Size.produce_unknown
    , tags            = []
    , availability    = Availability.unknown
    , discount        = Nothing
    }



set_name_to : String -> Model -> Model
set_name_to newName (Class record) =
  Class
    { name            = newName
    , id              = record.id
    , imageThumbnail  = record.imageThumbnail
    , brand           = record.brand
    , variant         = record.variant
    , listPrice       = record.listPrice
    , size            = record.size
    , tags            = record.tags
    , availability    = record.availability
    , discount        = record.discount
    }



set_id_to : String -> Model -> Model
set_id_to newId (Class record) =
  Class
    { name            = record.id
    , id              = newId
    , imageThumbnail  = record.imageThumbnail
    , brand           = record.brand
    , variant         = record.variant
    , listPrice       = record.listPrice
    , size            = record.size
    , tags            = record.tags
    , availability    = record.availability
    , discount        = record.discount
    }



set_thumbnail_to : String -> Model -> Model
set_thumbnail_to newUrl (Class record) =
  Class
    { name            = record.name
    , id              = record.id
    , imageThumbnail  = newUrl 
    , brand           = record.brand
    , variant         = record.variant
    , listPrice       = record.listPrice
    , size            = record.size
    , tags            = record.tags
    , availability    = record.availability
    , discount        = record.discount
    }



set_brand_to : String -> Model -> Model
set_brand_to newBrand (Class record) =
  Class
    { name            = record.name
    , id              = record.id
    , imageThumbnail  = record.imageThumbnail 
    , brand           = newBrand
    , variant         = record.variant
    , listPrice       = record.listPrice
    , size            = record.size
    , tags            = record.tags
    , availability    = record.availability
    , discount        = record.discount
    }



set_variant_to : String -> Model -> Model
set_variant_to newVariant (Class record) =
  Class
    { name            = record.name
    , id              = record.id
    , imageThumbnail  = record.imageThumbnail 
    , brand           = record.brand
    , variant         = newVariant
    , listPrice       = record.listPrice
    , size            = record.size
    , tags            = record.tags
    , availability    = record.availability
    , discount        = record.discount
    }



set_list_price_to : Float -> Model -> Model
set_list_price_to newListPrice (Class record) =
  Class
    { name            = record.name
    , id              = record.id
    , imageThumbnail  = record.imageThumbnail 
    , brand           = record.brand
    , variant         = record.variant
    , listPrice       = newListPrice
    , size            = record.size
    , tags            = record.tags
    , availability    = record.availability
    , discount        = record.discount
    }



set_size_to : Size.Model -> Model -> Model
set_size_to size (Class record) =
  Class
    { name            = record.name
    , id              = record.id
    , imageThumbnail  = record.imageThumbnail 
    , brand           = record.brand
    , variant         = record.variant
    , listPrice       = record.listPrice
    , size            = size
    , tags            = record.tags
    , availability    = record.availability
    , discount        = record.discount
    }



set_tags_to : List Tag.Model -> Model -> Model
set_tags_to tags (Class record) =
  Class
    { name            = record.name
    , id              = record.id
    , imageThumbnail  = record.imageThumbnail 
    , brand           = record.brand
    , variant         = record.variant
    , listPrice       = record.listPrice
    , size            = record.size
    , tags            = tags
    , availability    = record.availability
    , discount        = record.discount
    }



set_availability_to : Availability.Model -> Model -> Model
set_availability_to availability (Class record) =
  Class
    { name            = record.name
    , id              = record.id
    , imageThumbnail  = record.imageThumbnail 
    , brand           = record.brand
    , variant         = record.variant
    , listPrice       = record.listPrice
    , size            = record.size
    , tags            = record.tags
    , availability    = availability
    , discount        = record.discount
    }



set_discount_to : Maybe Discount.Model -> Model -> Model
set_discount_to discount (Class record) =
  Class
    { name            = record.name
    , id              = record.id
    , imageThumbnail  = record.imageThumbnail 
    , brand           = record.brand
    , variant         = record.variant
    , listPrice       = record.listPrice
    , size            = record.size
    , tags            = record.tags
    , availability    = record.availability
    , discount        = discount
    }
  


get_id_of : Model -> String
get_id_of (Class item) = item.id



get_name_of : Model -> String
get_name_of (Class item) = item.name



get_brand_of : Model -> String
get_brand_of (Class item) = item.brand



get_variant_of : Model -> String
get_variant_of (Class item) =  item.variant



get_availability_of : Model -> Availability.Model
get_availability_of (Class item) = item.availability



get_size_of : Model -> Size.Model
get_size_of (Class item) = item.size



get_thumbnail_url_of : Model -> String
get_thumbnail_url_of (Class item) = item.imageThumbnail



get_list_price_of : Model -> Float
get_list_price_of (Class item) = item.listPrice



get_tags_on : Model -> List Tag.Model
get_tags_on (Class item) = item.tags




get_sale_price_of : Model -> Float
get_sale_price_of item =
  let listPrice =  get_list_price_of item
      possibleDiscount = get_possible_discount_on item
  in case possibleDiscount of
       Nothing -> listPrice
       Just discount ->
         Round.roundNum
           2
           (Discount.apply_discount_to_price listPrice discount)



get_possible_discount_on : Model -> Maybe Discount.Model
get_possible_discount_on (Class item) = item.discount



get_discount_percentage_on : Model -> Int
get_discount_percentage_on item =
  let possibleDiscount = get_possible_discount_on item
  in case possibleDiscount of
       Nothing -> 0
       Just discount -> Discount.produce_percentage_of discount



-- DUMMY DATA

produce_random_name_from_seed : Int -> String
produce_random_name_from_seed seed =
  let mapper x =
        case x of
          0 -> "chicken legs"
          1 -> "fried tortilla chips from mexican desert"
          2 -> "ground beaf"
          3 -> "ice cream"
          4 -> "sliced bread"
          5 -> "tuna"
          6 -> "tomato sauce"
          7 -> "canned pees"
          8 -> "ketchup"
          _ -> "mustard"
      generator = Random.map mapper (Random.int 0 9)
  in Random.step generator (Random.initialSeed seed) |> Tuple.first



produce_random_thumbnail_url_from_seed : Int -> String
produce_random_thumbnail_url_from_seed seed =
  let mapper x =
        case x of
          0 -> "https://i5.walmartimages.com/asr/dd8a264c-63d9-4b63-9aa2-abfc5dfda42b.c3c8009c232e2ad162c7d59d040e93c1.jpeg?odnWidth=282&odnHeight=282&odnBg=ffffff"
          1 -> "https://i5.walmartimages.com/asr/9c0c120d-5d72-47a7-a911-fcc77d9067cc.3d6462b9c9aa37137bdba817068a51df.jpeg?odnWidth=234&odnHeight=234&odnBg=ffffff"
          2 -> "https://i5.walmartimages.com/asr/a3f5fedd-509f-4a4a-a57d-1aabd528a3fd_1.171823749710f1942b08b09797eeb875.jpeg?odnWidth=234&odnHeight=234&odnBg=ffffff"
          3 -> "https://i5.walmartimages.com/asr/ed2332de-9a18-4ffa-8721-54f74071ed52_1.66eb06234341220ce87321a9acf41603.jpeg?odnWidth=234&odnHeight=234&odnBg=ffffff"
          4 -> "https://i5.walmartimages.com/dfw/4ff9c6c9-b006/k2-_9c1d502f-c08d-4591-a734-b205d0ffe45b.v1.jpg?odnWidth=282&odnHeight=282&odnBg=ffffff"
          5 -> "https://i5.walmartimages.com/dfw/4ff9c6c9-b691/k2-_95cdb69e-5175-408a-b18e-7c8a4902da65.v1.jpg?odnWidth=282&odnHeight=282&odnBg=ffffff"
          6 -> "https://i5.walmartimages.com/dfw/4ff9c6c9-c487/k2-_0b0b1864-112c-4323-9474-9556739bf3b5.v1.jpg?odnWidth=282&odnHeight=282&odnBg=ffffff"
          7 -> "https://i5.walmartimages.com/asr/2354d9ab-c9d2-461a-8bd8-85aa4e7c4750_1.ba9090269e3db50e41c1b5ecc79b510b.jpeg?odnWidth=180&odnHeight=180&odnBg=ffffff"
          8 -> "https://i5.walmartimages.com/asr/62d59583-f653-493e-8c68-2a583b17267b_1.976330d8854264a2a638feb451d34aae.jpeg?odnWidth=180&odnHeight=180&odnBg=ffffff"
          _ -> "https://i5.walmartimages.com/asr/4a449b25-d392-497b-8ae9-bab5d250fc57_1.940820ed0b70741cc3b132091cd1b201.jpeg?odnWidth=180&odnHeight=180&odnBg=ffffff"
      generator = Random.map mapper (Random.int 0 9)
  in Random.step generator (Random.initialSeed seed) |> Tuple.first



produce_random_brand_from_seed : Int ->  String
produce_random_brand_from_seed seed =
  let mapper x =
        case x of
          0 -> "quality chicken"
          1 -> "doritos"
          2 -> "green giant"
          3 -> "wester dairies"
          4 -> "la popular"
          5 -> "red rose"
          6 -> "grace"
          7 -> "local"
          8 -> "marie shaprs"
          _ -> "egypt"
      generator = Random.map mapper (Random.int 0 9)
  in Random.step generator (Random.initialSeed seed) |> Tuple.first



produce_random_variant_from_seed : Int -> String
produce_random_variant_from_seed seed =
  let mapper x =
        case x of
          0 -> "bag"
          1 -> "can"
          2 -> "green"
          _ -> "red"
      generator = Random.map mapper (Random.int 0 3)
  in Random.step generator (Random.initialSeed seed) |> Tuple.first



produce_random_item : Int -> Model
produce_random_item seed =
  let tags = List.map
               (\i -> Tag.produce_random_tag_from_seed (seed+i))
               (List.range 1 8)
      availability =
        Availability.produce_random_availability_from_seed seed
      discount =
        if SRandom.randomInt 0 1 seed == 1
          then Just (Discount.produce_random_discount_from_seed seed)
          else Nothing

  in Class   { name            = produce_random_name_from_seed seed
             , id              = SRandom.produce_random_id seed
             , imageThumbnail  = produce_random_thumbnail_url_from_seed
                                   seed
             , brand           = produce_random_brand_from_seed seed
             , variant         = produce_random_variant_from_seed seed
             , listPrice       = SRandom.randomFloat2 1.0 2000.0 seed
             , size            = Size.produce_random_size seed
             , tags            = tags
             , availability    = availability
             , discount        = discount
             }
