module Item exposing
  ( Model
  , Data
  , DiscountData
  , Availability
  , ValidationErr(..)
  , produce_new_summary_from_data
  , blankSummary
  , produce_id_of
  , produce_name_of
  , produce_thumbnail_url
  , produce_size_of
  , produce_variant_of
  , produce_list_price
  , produce_sale_price
  , produce_discount_percentage
  , produce_brand_of
  , convert_to_data
  , produce_random_summary
  )

import Time
import Round
import Random
import SRandom
import UUID
import Size


-----------------------------------------------------------------------
-- CONSTANT DEFINITIONS
-----------------------------------------------------------------------

blankSummaryRecord : SummaryRecord
blankSummaryRecord =
  { name            = ""
  , id              = "0"
  , imageThumbnail  = ""
  , brand           = ""
  , variant         = ""
  , listPrice       = 0.0
  , size            = Size.produce_large
  , departmentTags  = []
  , categoryTags    = []
  , subCategoryTags = []
  , searchTags      = []
  , availability    = OUT_STOCK
  , discount        = Nothing
  }


blankSummary : Model
blankSummary = Summary blankSummaryRecord


-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

{-| represents a summary descriptions of a single type of inventory
item.

**size:** the item size can be either an exact size like "50 mg" or
a vague size such as "large".

**listPrice:** the item price before a discount is applied.

**availability:** the items availability in stock.

**departmentTags:** a collection of tags, each representing a department
the item should be in.

**categoryTags:** A collections of tags, each representing a department
category the item should be in. This serves to sub-devides individual
departments.

**subCategoryTags:** A collection of tags, each representing a
department sub-category the item should be in. This serves to further
sub-devide individual departments.

**searchTags:** these are tags used to aid in searching for this item.

example:

  record : Item.SummaryRecord
  record =
    { name            = "chicken legs"
    , id              = "CHKCCS1233"
    , imageThumbnail  = "https://www.example.com/chicken.jpg"
    , brand           = "caribbean chicken"
    , variant         = "bag"
    , listPrice       = 15.93
    , size            = Size.produce_ml_interpretation_of_float 1000.5
    , departmentTags  = [ DepartmentTag
                            { id = "UID789"
                            , name = "deptTag"
                            }
                        ]
    , categoryTags    = [ CategoryTag
                            { id = "UID456"
                            , name = "catTag"
                            }
                        ]
    , subCategoryTags = [ SubCategoryTag
                            { id   = "UID4123"
                            , name = "subCatTag"
                            }
                        ]
    , searchTags      = [ SearchTag
                            { id   = "UID333"
                            , name = "searchTag"
                            }
                        ]
    , availability    = IN_STOCK
    , discount        = Just <| Discount
                          { discount_code = "UXDS9y3"
                          , name          = "seafood giveaway"
                          , value         = 15.0
                          , items         = ["CHKCCS1233"]
                          }
    }
-}
type Model = Summary SummaryRecord

type alias SummaryRecord =
  { name            : String
  , id              : String
  , imageThumbnail  : String
  , brand           : String
  , variant         : String
  , listPrice       : Float
  , size            : Size.Model
  , departmentTags  : List Tag
  , categoryTags    : List Tag
  , subCategoryTags : List Tag
  , searchTags      : List Tag
  , availability    : Availability
  , discount        : Maybe Discount
  }



{-| Represents the information necessary to build a new SummaryRecord. All
fields hold simple string data or "subrecords" of string data.

All fields match one to one with the fields in SummaryRecord.

example:
  data =
    { name            = "chicken legs"
    , id              = "CHKCCS1233"
    , imageThumbnail  = "https://www.example.com/chicken.jpg"
    , brand           = "caribbean chicken"
    , variant         = "bag"
    , listPrice       = "15.93"
    , size            = "1000.5 mg"
    , departmentTags  = [ { id = "UID789"
                          , name = "deptTag"
                          }
                        ]
    , categoryTags    = [ { id = "UID456"
                          , name = "catTag"
                          }
                        ]
    , subCategoryTags = [ { id   = "UID4123"
                          , name = "subCatTag"
                          }
                        ]
    , searchTags      = [ { id   = "UID333"
                          , name = "searchTag"
                          }
                        ]
    , availability    = "in_stock"
    , discount        = { discount_code = "UXDS9y3"
                        , name          = "seafood giveaway"
                        , value         = "15"
                        , items         = ["CHKCCS1233"]
                        }
    }
-}
type alias Data =
  { name            : String
  , id              : String
  , imageThumbnail  : String
  , brand           : String
  , variant         : String
  , listPrice       : String
  , size            : String
  , departmentTags  : List { id : String, name : String }
  , categoryTags    : List { id : String, name : String }
  , subCategoryTags : List { id : String, name : String }
  , searchTags      : List { id : String, name : String }
  , availability    : String
  , discount        : Maybe DiscountData
  }



{-| If a user of this module attempts to create a new item with
invalid data, that will result in an ValidationErr. The first
field of ValidationErr is the id of the data item used in the
attempt, the second is the errant value used in the attempt.
Whenever a third field is present it represents the field name
holding the errant data.

example:
  priceErr = NaNPrice "ID123" "$124"

  avErr = InvalidAvailability "ID123" "out of stock"

  --                            item id  value  field
  discountErr = InvalidDiscount String   "so"   "value"

-}
type ValidationErr
  = NaNPrice             String String
  | NegativePrice        String String
  | InvalidAvailability  String String
  | InvalidDiscount      String String String
  | NullId
  | SizeError            Size.Error


type Discount = Discount DiscountR



{-| Represents the information necessary to build a new
Discount. All fields hold simple string data or "subrecords".

All fields match one to one with the fields in DiscountR.
-}
type alias DiscountData =
  { discount_code    : String
  , name             : String
  , value            : String
  , items            : List String
  }



{-| Represents a discount that is automatically applied to a select
item.

**discount_code:** unique identifier for the given discount
**name:** user friendly name for the discount
**value:** percent value of the discount.
**items:** the ids for the items this discount applies to.

example:

itemDiscount : Discount
itemDiscount =
  { discount_code = "UXDS9y3"
  , name          = "seafood giveaway"
  , value         = 15
  , iems          = ["CHKCCS1233"]
  }
-}
type alias DiscountR =
  { discount_code    : String
  , name             : String
  , value            : Int
  , items            : List String
  }



{-| represents the availability of inventory items of a given type.

**IN_STOCK**   - represents a type of item that is currently in stock.

**OUT_STOCK**  - represents a type of item that is currently out of
stock.
**ORDER_ONLY** - represents a type of item that is available on a
per order basis.

  examples:

  availability1 : Availability
  availability1 = IN_STOCK
  
  availability2 : Availability
  availability2 = OUT_STOCK
  
  availability3 : Availability
  availability3 = ORDER_ONLY
-}
type Availability
  = IN_STOCK
  | ORDER_ONLY
  | OUT_STOCK



type Tag
  = DepartmentTag TagR
  | CategoryTag TagR
  | SubCategoryTag TagR
  | SearchTag TagR



{-| represents a single tag used to categorize a group of items.

examples: 

  tag1 : Entity.TagR
  tag1 =
    { id   = "UID4123"
    , name = "foods"
    }
-}
type alias TagR =
  { id    : String
  , name  : String
  }



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

{-| Validate the given input data and produce a new Item
from the given data record or ValidationErr if any of the data
is invalid.

example:

  itemData =
    { name            = "chicken legs"
    , id              = "CHKCCS1233"
    , imageThumbnail  = "https://www.example.com/chicken.jpg"
    , brand           = "caribbean chicken"
    , variant         = "bag"
    , price           = "15.93"
    , size            = "1000.5 mg"
    , departmentTags  = [ { id = "UID789"
                          , name = "deptTag"
                          }
                        ]
    , categoryTags    = [ { id = "UID456"
                          , name = "catTag"
                          }
                        ]
    , subCategoryTags = [ { id   = "UID4123"
                          , name = "subCatTag"
                          }
                        ]
    , searchTags      = [ { id   = "UID333"
                          , name = "searchTag"
                          }
                        ]
    , availability    = "in_stock"
    , discount        = { discount_code = "UXDS9y3"
                        , name          = "seafood giveaway"
                        , value         = "15"
                        , iems          = ["CHKCCS1233"]
                        }
    }

  produce_new_summary_from_data itemData ==
    Summary
      { name            = "chicken legs"
      , id              = "CHKCCS1233"
      , imageThumbnail  = "https://www.example.com/chicken.jpg"
      , brand           = "caribbean chicken"
      , variant         = "bag"
      , price           = 15.93
      , size            = Size.produce_mg_interpretation_of_float 1000.5
      , departmentTags  = [ DepartmentTag { id = "UID789"
                                          , name = "deptTag"
                                          }
                          ]
      , categoryTags    = [ CategoryTag { id = "UID456"
                                        , name = "catTag"
                                        }
                          ]
      , subCategoryTags = [ SubCategoryTag { id   = "UID4123"
                                           , name = "subCatTag"
                                           }
                          ]
      , searchTags      = [ SearchTag { id   = "UID333"
                                      , name = "searchTag"
                                      }
                          ]
      , availability    = IN_STOCK
      , discount        = Discount
                            { discount_code = "UXDS9y3"
                            , name          = "seafood giveaway"
                            , value         = "15"
                            , items         = ["CHKCCS1233"]
                            }
      }
-}
produce_new_summary_from_data : Data -> Result ValidationErr Model
produce_new_summary_from_data data =
  case validate_summary_data data of
    Err err -> Err err
    Ok validData -> 
      Ok
        <| Summary
             { name            = validData.name
             , id              = validData.id
             , imageThumbnail  = validData.imageThumbnail
             , brand           = validData.brand
             , variant         = validData.variant
             , listPrice       = validData.listPrice
                                   |> String.toFloat
                                   |> Maybe.withDefault 0
             , size            =
               Size.attempt_size_interpretation_of_string
                 validData.size
                 |> Result.withDefault Size.produce_large
             , departmentTags  = List.map
                                   DepartmentTag
                                   validData.departmentTags
             , categoryTags    = List.map
                                   CategoryTag
                                   validData.departmentTags
             , subCategoryTags = List.map
                                   SubCategoryTag
                                   validData.departmentTags
             , searchTags      = List.map
                                   SearchTag
                                   validData.departmentTags
             , availability    = maybe_produce_availability_from_string
                                   validData.availability
                                   |> Maybe.withDefault OUT_STOCK
             , discount        = maybe_produce_discount_from_data
                                   validData.discount
             }



convert_to_data : Model -> Data
convert_to_data item =
  let (Summary record) = item
  in
    { name            = item |> produce_name_of
    , id              = item |> produce_id_of
    , imageThumbnail  = item |> produce_thumbnail_url
    , brand           = item |> produce_brand_of
    , variant         = item |> produce_variant_of
    , listPrice       = item |> produce_list_price >> String.fromFloat
    , size            =
      Size.produce_string_representation_of (item |> size)
    , departmentTags  = map_tags_to_data record.departmentTags
    , categoryTags    = map_tags_to_data record.categoryTags
    , subCategoryTags = map_tags_to_data record.subCategoryTags
    , searchTags      = map_tags_to_data record.searchTags
    , availability    = item |> produce_availability_as_string
    , discount        = item |> maybe_produce_discount_data
    }



produce_availability_as_string : Model -> String
produce_availability_as_string item =
  case item |> produce_availability of
    IN_STOCK    ->  "in_stock"    
    OUT_STOCK   ->  "out_stock"   
    ORDER_ONLY  ->  "order_only"  



map_tags_to_data : List Tag -> List TagR
map_tags_to_data tags =
  let tag_to_data tag = 
        case tag of
          (DepartmentTag data)   -> data
          (CategoryTag data)     -> data
          (SubCategoryTag data)  -> data
          (SearchTag data)       -> data
  in List.map tag_to_data tags



maybe_produce_discount_data : Model -> Maybe DiscountData
maybe_produce_discount_data item =
  let maybeDiscount = item |> maybe_produce_discount
  in case maybeDiscount of
       Nothing -> Nothing
       Just (Discount discountR) -> 
         Just { discount_code = discountR.discount_code
              , name = discountR.name
              , value = String.fromInt discountR.value
              , items = discountR.items
              }



maybe_produce_discount_from_data : Maybe DiscountData -> Maybe Discount
maybe_produce_discount_from_data maybeData =
  case maybeData of
    Nothing -> Nothing
    Just data ->
      Just <| Discount { discount_code = .discount_code data
                       , name          = .name data
                       , value         = .value data
                                           |> String.toInt
                                           |> Maybe.withDefault 0
                       , items         = .items data
                       }


validate_summary_data : Data -> Result ValidationErr Data
validate_summary_data data =
    data
      |> validate_data_id
      |> Result.andThen validate_price_data
      |> Result.andThen validate_size_data
      |> Result.andThen validate_availability_data
      |> Result.andThen validate_discount_percentage_data



validate_data_id : Data -> Result ValidationErr Data
validate_data_id data =
  if (data.id |> String.length) <= 0
    then Err <| NullId
    else Ok data



validate_price_data : Data -> Result ValidationErr Data
validate_price_data data = 
  case .listPrice data |> String.toFloat of
    Nothing -> Err <| NaNPrice data.id (.listPrice data)
    Just listPriceAsFloat ->
      if listPriceAsFloat < 0
        then Err <| NegativePrice data.id (.listPrice data)
        else Ok data



validate_size_data : Data -> Result ValidationErr Data
validate_size_data data =
  let possibleSize =
        Size.attempt_size_interpretation_of_string (.size data)
  in case possibleSize  of
       Err error -> Err <| SizeError error
       Ok _ -> Ok data



validate_availability_data : Data -> Result ValidationErr Data
validate_availability_data data = 
  let maybeAvailability =
        maybe_produce_availability_from_string (.availability data)
  in case maybeAvailability of
       Nothing ->
         Err <| InvalidAvailability data.id (.availability data)
       Just availability ->
         Ok data



validate_discount_percentage_data : Data -> Result ValidationErr Data
validate_discount_percentage_data data = 
  let maybeDiscountData = .discount data
  in case maybeDiscountData of
       Nothing -> Ok data
       Just discountData ->
         let maybeDiscountPercentage =
               discountData.value |> String.toInt
             invalidDiscountPercentage =
               InvalidDiscount data.id discountData.value "value"
         in case maybeDiscountPercentage of
              Nothing -> Err invalidDiscountPercentage
              Just discountPercentage -> Ok data



maybe_produce_availability_from_string : String -> Maybe Availability
maybe_produce_availability_from_string strAvailability =
  case strAvailability |> String.toLower >> String.trim of
    "in_stock"    -> Just IN_STOCK
    "out_stock"   -> Just OUT_STOCK
    "order_only"  -> Just ORDER_ONLY
    _             -> Nothing



produce_id_of : Model -> String
produce_id_of (Summary item) = item.id



produce_name_of : Model -> String
produce_name_of (Summary item) = item.name



produce_brand_of : Model -> String
produce_brand_of (Summary item) = item.brand



produce_variant_of : Model -> String
produce_variant_of (Summary item) =  item.variant



produce_availability : Model -> Availability
produce_availability (Summary item) = item.availability



produce_size_of : Model -> Size.Model
produce_size_of (Summary item) = item.size
size = produce_size_of



produce_thumbnail_url : Model -> String
produce_thumbnail_url (Summary item) = item.imageThumbnail



produce_list_price : Model -> Float
produce_list_price (Summary item) = item.listPrice



produce_sale_price : Model -> Float
produce_sale_price item =
  let discountPercentage =
        item |> produce_discount_percentage >> toFloat
      listPrice = item |> produce_list_price
  in Round.roundNum 2 (listPrice * (discountPercentage/100))



maybe_produce_discount : Model -> Maybe Discount 
maybe_produce_discount (Summary item) = item.discount



produce_discount_percentage : Model -> Int
produce_discount_percentage item =
  case item |> maybe_produce_discount of
    Nothing -> 0
    Just (Discount discount) ->
      discount.value



-- DUMMY DATA

produce_random_name : Int -> String
produce_random_name seed =
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



produce_random_thumbnail_url : Int -> String
produce_random_thumbnail_url seed =
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



produce_random_brand : Int ->  String
produce_random_brand seed =
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



produce_random_variant : Int -> String
produce_random_variant seed =
  let mapper x =
        case x of
          0 -> "bag"
          1 -> "can"
          2 -> "green"
          _ -> "red"
      generator = Random.map mapper (Random.int 0 3)
  in Random.step generator (Random.initialSeed seed) |> Tuple.first



produce_random_availability : Int -> Availability
produce_random_availability seed =
  let mapper x =
        case x of
          1 -> IN_STOCK
          2 -> OUT_STOCK
          _ -> ORDER_ONLY
      generator = Random.map mapper (Random.int 1 3)
  in Random.step generator (Random.initialSeed seed) |> Tuple.first



produce_random_availability_string : Int -> String
produce_random_availability_string seed =
  let mapper x =
        case x of
          1 -> "IN_STOCK"
          2 -> "OUT_STOCK"
          _ -> "ORDER_ONLY"
      generator = Random.map mapper (Random.int 1 3)
  in Random.step generator (Random.initialSeed seed) |> Tuple.first



produce_random_id : Int -> String
produce_random_id seed =
  Random.step UUID.generator (Random.initialSeed seed)
    |> Tuple.first
    |> UUID.toString



produce_random_discount : Int -> DiscountData
produce_random_discount seed =
  { discount_code    = produce_random_id seed
  , name             = produce_random_variant seed
  , value            = String.fromInt (SRandom.randomInt 1 25 seed)
  , items            = List.map
                         (\i ->
                           let seed_ = seed+i
                           in produce_random_id seed_
                         ) <| List.range 0 8
  }



produce_random_data : Int -> Data
produce_random_data seed =
  { name            = produce_random_name seed
  , id              = produce_random_id seed
  , imageThumbnail  = produce_random_thumbnail_url seed
  , brand           = produce_random_brand seed
  , variant         = produce_random_variant seed
  , listPrice       = Round.round 2 (SRandom.randomFloat seed)
  , size            = Size.produce_random_size_string seed
  , departmentTags  = [
                          { id = "UID789"
                          , name = "deptTag"
                          }
                      ]
  , categoryTags    = [
                          { id = "UID456"
                          , name = "catTag"
                          }
                      ]
  , subCategoryTags = [
                          { id   = "UID4123"
                          , name = "subCatTag"
                          }
                      ]
  , searchTags      = [ 
                          { id   = "UID333"
                          , name = "searchTag"
                          }
                      ]
  , availability    = produce_random_availability_string seed
  , discount        = if SRandom.randomInt 0 1 seed == 1
                        then Just (produce_random_discount seed)
                        else Nothing
  }



produce_random_summary : Int -> Model
produce_random_summary seed =
  case produce_new_summary_from_data (produce_random_data seed) of
    Err _ -> blankSummary
    Ok brief -> brief

