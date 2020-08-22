module Item exposing
  ( Model
  , Data
  , ValidationErr(..)
  , produce_new_summary_from_data
  , blankSummary
  , produce_id_of
  , produce_name_of
  , produce_thumbnail_url_of
  , produce_size_of
  , produce_variant_of
  , produce_list_price_of
  , produce_sale_price_of
  , produce_discount_percentage_on
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
import Discount
import Availability


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
  , availability    = Availability.out_of_stock
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
  , availability    : Availability.Model
  , discount        : Maybe Discount.Model
  }



{-| Represents the information necessary to build a new SummaryRecord. All
fields hold simple string data or "subrecords" of string data.

All fields match one to one with the fields in SummaryRecord.
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
  , discount        : Maybe Discount.Data
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
  | AvailabilityError    Availability.Error
  | NullId
  | DiscountError        Discount.Error
  | SizeError            Size.Error



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

-}
produce_new_summary_from_data : Data -> Result ValidationErr Model
produce_new_summary_from_data unvalidatedData =
  case validate_summary_data unvalidatedData of
    Err err -> Err err
    Ok data -> 
      let discount = 
            case .discount data of
              Nothing -> Nothing
              Just discountData ->
                Just (Discount.produce_discount_from_valid_data
                        discountData
                     )
      in Ok
           <| Summary
                { name            = .name data
                , id              = data.id
                , imageThumbnail  = .imageThumbnail data
                , brand           = .brand data
                , variant         = .variant data
                , listPrice       = .listPrice data
                                      |> String.toFloat
                                      |> Maybe.withDefault 0
                , size            =
                  Size.parse_string (.size data)
                    |> Result.withDefault Size.produce_large
                , departmentTags  = List.map
                                      DepartmentTag (.departmentTags data)
                , categoryTags    = List.map
                                      CategoryTag (.categoryTags data)
                , subCategoryTags = List.map
                                      SubCategoryTag
                                      (.subCategoryTags data)
                , searchTags      = List.map
                                      SearchTag
                                      (.searchTags data)
                , availability    =
                    Availability.parse_string (.availability data)
                      |> Result.withDefault Availability.out_of_stock
                , discount        = discount
                }



convert_to_data : Model -> Data
convert_to_data item =
  let (Summary record) = item
      possibleDiscount = produce_possible_discount_on item
      to_discount_data = Discount.produce_data_from
      mapped_to_possible_discount_data = Maybe.map to_discount_data
      sizeData = Size.stringify (item |> size)
  in
    { name            = item |> produce_name_of
    , id              = item |> produce_id_of
    , imageThumbnail  = item |> produce_thumbnail_url_of
    , brand           = item |> produce_brand_of
    , variant         = item |> produce_variant_of
    , listPrice       = item |> produce_list_price_of >> String.fromFloat
    , size            = sizeData
    , departmentTags  = map_tags_to_data record.departmentTags
    , categoryTags    = map_tags_to_data record.categoryTags
    , subCategoryTags = map_tags_to_data record.subCategoryTags
    , searchTags      = map_tags_to_data record.searchTags
    , availability    = produce_availability_of item 
                          |> Availability.stringify
    , discount        = possibleDiscount
                          |> mapped_to_possible_discount_data
    }



map_tags_to_data : List Tag -> List TagR
map_tags_to_data tags =
  let tag_to_data tag = 
        case tag of
          (DepartmentTag data)   -> data
          (CategoryTag data)     -> data
          (SubCategoryTag data)  -> data
          (SearchTag data)       -> data
  in List.map tag_to_data tags



validate_summary_data : Data -> Result ValidationErr Data
validate_summary_data data =
    data
      |> validate_data_id_of
      |> Result.andThen validate_price_data_of
      |> Result.andThen validate_size_data_of
      |> Result.andThen validate_availability_data_of
      |> Result.andThen validate_discount_data_of



validate_discount_data_of : Data -> Result ValidationErr Data
validate_discount_data_of data =
  let possibleDiscount = .discount data
  in case possibleDiscount of
       Nothing -> Ok data
       Just discountData ->
         case Discount.validate_discount_data discountData of
           Err error -> Err <| DiscountError error
           Ok validData -> Ok data



validate_data_id_of : Data -> Result ValidationErr Data
validate_data_id_of data =
  if (data.id |> String.length) <= 0
    then Err <| NullId
    else Ok data



validate_price_data_of : Data -> Result ValidationErr Data
validate_price_data_of data = 
  case .listPrice data |> String.toFloat of
    Nothing -> Err <| NaNPrice data.id (.listPrice data)
    Just listPriceAsFloat ->
      if listPriceAsFloat < 0
        then Err <| NegativePrice data.id (.listPrice data)
        else Ok data



validate_size_data_of : Data -> Result ValidationErr Data
validate_size_data_of data =
  let possibleSize =
        Size.parse_string (.size data)
  in case possibleSize  of
       Err error -> Err <| SizeError error
       Ok _ -> Ok data



validate_availability_data_of : Data -> Result ValidationErr Data
validate_availability_data_of data = 
  let possibleAvailability =
        Availability.parse_string (.availability data)
  in case possibleAvailability of
       Err availabilityError ->
         Err <| AvailabilityError availabilityError
       Ok _ -> Ok data



produce_id_of : Model -> String
produce_id_of (Summary item) = item.id



produce_name_of : Model -> String
produce_name_of (Summary item) = item.name



produce_brand_of : Model -> String
produce_brand_of (Summary item) = item.brand



produce_variant_of : Model -> String
produce_variant_of (Summary item) =  item.variant



produce_availability_of : Model -> Availability.Model
produce_availability_of (Summary item) = item.availability



produce_size_of : Model -> Size.Model
produce_size_of (Summary item) = item.size
size = produce_size_of



produce_thumbnail_url_of : Model -> String
produce_thumbnail_url_of (Summary item) = item.imageThumbnail



produce_list_price_of : Model -> Float
produce_list_price_of (Summary item) = item.listPrice



produce_sale_price_of : Model -> Float
produce_sale_price_of item =
  let listPrice =  produce_list_price_of item
      possibleDiscount = produce_possible_discount_on item
  in case possibleDiscount of
       Nothing -> listPrice
       Just discount ->
         Round.roundNum
           2
           (Discount.apply_discount_to_price listPrice discount)



produce_possible_discount_on : Model -> Maybe Discount.Model
produce_possible_discount_on (Summary item) = item.discount



produce_discount_percentage_on : Model -> Int
produce_discount_percentage_on item =
  let possibleDiscount = produce_possible_discount_on item
  in case possibleDiscount of
       Nothing -> 0
       Just discount -> Discount.produce_percentage_of discount



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



produce_random_data : Int -> Data
produce_random_data seed =
  { name            = produce_random_name seed
  , id              = SRandom.produce_random_id seed
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
  , availability    =
    Availability.stringify
      <| Availability.produce_random_availability_from_seed seed
  , discount        =
    if SRandom.randomInt 0 1 seed == 1
      then Just (Discount.produce_random_data_from_seed seed)
      else Nothing
  }



produce_random_summary : Int -> Model
produce_random_summary seed =
  case produce_new_summary_from_data (produce_random_data seed) of
    Err _ -> blankSummary
    Ok brief -> brief

