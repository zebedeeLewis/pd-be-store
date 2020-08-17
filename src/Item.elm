module Item exposing
  ( Model
  , SummaryDataR
  , DiscountDataR
  , Set
  , Size
  , Measure
  , Availability
  , ValidationErr(..)
  , listFromSet
  , newSummary
  , priceToPair
  , querySetFor
  , priceToString
  , blankSummary
  , emptySet
  , addToSet
  , setToData
  , equal
  , id
  , sizeToString
  , name
  , image
  , size
  , variant
  , listPrice
  , salePrice
  , brand
  , toData
  , dataListToSet
  , availabilityToStr
  , discountPct
  , randomSet
  , randomItemSummary
  , randomItemSummaryData
  , randomId
  , randomTag
  , randomStrSize
  , randomStrAvailability
  , randomVariant
  , randomBrand
  , randomImageUrl
  , randomItemName
  -- , randomDiscount
  -- , randomSize
  -- , randomAvailability
  )

import Time
import Round
import Random
import SRandom
import UUID


-----------------------------------------------------------------------
-- CONSTANT DEFINITIONS
-----------------------------------------------------------------------

litre = 1000           -- ml
gallon = 4547          -- ml
cubicMetre = 1000000   -- cubic cm
gram = 1000            -- mg
kilogram = 1000000     -- mg
centimetre = 10        -- mm
metre = 1000           -- mm


blankSummaryR : SummaryR
blankSummaryR =
  { name            = ""
  , id              = "0"
  , imageThumbnail  = ""
  , brand           = ""
  , variant         = ""
  , listPrice       = 0.0
  , size            = LG
  , departmentTags  = []
  , categoryTags    = []
  , subCategoryTags = []
  , searchTags      = []
  , availability    = OUT_STOCK
  , discount        = Nothing
  }


blankSummary : Model
blankSummary = Summary blankSummaryR


emptySet : Set
emptySet = Set [] []



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

**searchTags:** A collection of tags, these are tags used to aid in
searching for this item.

example:

  record : Item.SummaryR
  record =
    { name            = "chicken legs"
    , id              = "CHKCCS1233"
    , imageThumbnail  = "https://www.example.com/chicken.jpg"
    , brand           = "caribbean chicken"
    , variant         = "bag"
    , listPrice       = 15.93
    , size            = Grad 1000.5 MG
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
type alias SummaryR =
  { name            : String
  , id              : String
  , imageThumbnail  : String
  , brand           : String
  , variant         : String
  , listPrice       : Float
  , size            : Size
  , departmentTags  : List Tag
  , categoryTags    : List Tag
  , subCategoryTags : List Tag
  , searchTags      : List Tag
  , availability    : Availability
  , discount        : Maybe Discount
  }


type Model = Summary SummaryR


{-| Represents the information necessary to build a new SummaryR. All
fields hold simple string data or "subrecords" of string data.

All fields match one to one with the fields in SummaryR.

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
type alias SummaryDataR =
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
  , discount        : Maybe DiscountDataR
  }


{-| If a user of this module attempts to create a new item with
invalid data, that will result in an ValidationErr. The first
field of ValidationErr is the id of the data item used in the
attempt, the second is the errant value used in the attempt.
Whenever a third field is present it represents the field name
holding the errant data.

example:
  priceErr = NaNPrice "ID123" "$124"

  sizeErr = InvalidSize "ID123" "invalid size"

  avErr = InvalidAvailability "ID123" "out of stock"

  --                            item id  value  field
  discountErr = InvalidDiscount String   "so"   "value"

-}
type ValidationErr
  = NaNPrice             String String
  | NegativePrice        String String
  | InvalidSize          String String
  | InvalidAvailability  String String
  | InvalidDiscount      String String String
  | NullId


type Discount = Discount DiscountR


{-| Represents the information necessary to build a new
Discount. All fields hold simple string data or "subrecords".

All fields match one to one with the fields in DiscountR.
-}
type alias DiscountDataR =
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


{-| Represents a collection of Item. A set can have one or more filters
applied to it.
-}
type Set = Set (List Filter) (List Model)


{-| represents a filter to be applied to an item set
-}
--                        value
type Filter = BrandFilter String


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


{-| represents the basic unit of measurement for length, volume and
weight.

example:

  measure1 : Measure
  measure1 = ML
  
  measure2 : Measure
  measure2 = MM
  
  measure3 : Measure
  measure3 = MG
-}
type Measure
  = ML
  | MM
  | CC
  | MG


{-| represents the size of an item, this can be an exact measurement
or an generic estimate such as large, extra-large etc.

Grad value measure
  value   - measurement value
  measure - the unit of measurement

examples:

  size1 : Size
  size1 = LG
  
  size2 : Size
  size2 = XL
  
  size3 : Size
  size3 = Grad 2.5 ML
-}
type Size
  = Grad Float Measure
  | LG
  | XL
  | SM
  | XS
  | M


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


{- TODO: This should be moved to a module dedicated to Users.  -}
type UserDiscount = UserDiscount UserDiscountR


{-| Represents a discount that the user has the option to apply. Once
applied the discount will take effect on a select set of items.

Has the exact set of fields as Discount along with the following
additional field:

**expirationTime:** the current time passes this expiration time, then
the discount is no longer valid.

**startingBalance:** user discounts cannot be applied beyond a certain
dollar amount. This represents the balance to that dollar cap before
the discount is applied.

**finalBalance:** represents the balance to the dollar cap after the
discount is applied.

examples:

  -- the startingBalance and finalBalance values are the same for
  -- unapplied discounts.
  userDiscount =
    { discount_code    = "DSC123"
    , name             = "marketing discount"
    , value            = 10
    , iems             = ["CHKCCS1233"]
    , expirationTime   = Time.millisToPosix 1596261755
    , startingBalance  = 58.6
    , finalBalance     = 58.6
    }

  -- the startingBalance is more than the finalBalance for applied
  -- discounts.
  appliedUserDiscount =
    { discount_code    = "DSC123"
    , name             = "marketing discount"
    , value            = 10
    , iems             = ["CHKCCS1233"]
    , expirationTime   = Time.millisToPosix 1596261755
    , startingBalance  = 58.6
    , finalBalance     = 23.6
    }

TODO: This should be moved to a module dedicated to Users.
-}
type alias UserDiscountR =
  { discount_code    : String
  , name             : String
  , value            : Float
  , items            : List String
  , expirationTime   : Time.Posix
  , startingBalance  : Float
  , finalBalance     : Float
  }



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

{-|
  produce a list of all Entity with the given tagName.
  TODO!!!
-}
filterBy
  : TagR
  -> List SummaryR
  -> List SummaryR
filterBy department items =
  items


{-| produce the string representation of an Size
Assumptions: we assume that the size is already rounded correct to
3 decimal places.
-}
sizeToString : Size -> String
sizeToString size_ =
  case size_ of
    Grad value measure ->
      case measure of
        ML -> (String.fromFloat value) ++ " ml" 
        CC -> (String.fromFloat value) ++ " cc"
        MG -> (String.fromFloat value) ++ " mg"
        MM -> (String.fromFloat value) ++ " mm"
    LG -> "LG"
    XL -> "XL"
    SM -> "SM"
    XS -> "XS"
    M  -> "M"


getTagR : Tag -> TagR
getTagR tag =
  case tag of
    DepartmentTag tag_ -> tag_
    CategoryTag tag_ -> tag_
    SubCategoryTag tag_ -> tag_
    SearchTag tag_ -> tag_


{-| produce a new Discount from the given tuple

example:

  discount = 
    ewDiscount "UXDS9y3" "seafood giveaway" 15.0 ["CHKCCS1233"]
-}
newDiscount
  : String
  -> String
  -> Int
  -> List String
  -> Discount
newDiscount  code name_ value items =
  Discount { discount_code = code
           , name          = name_
           , value         = value
           , items         = items
           }


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

  new itemData ==
    Summary
      { name            = "chicken legs"
      , id              = "CHKCCS1233"
      , imageThumbnail  = "https://www.example.com/chicken.jpg"
      , brand           = "caribbean chicken"
      , variant         = "bag"
      , price           = 15.93
      , size            = Grad 1000.5 MG
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
newSummary
  : SummaryDataR
  -> Result ValidationErr Model
newSummary itemData =
  let
    setCatTags = (\(v, d)->
                   let categories = List.map CategoryTag d.categoryTags
                   in ({ v | categoryTags = categories }, d))

    setDeptTags = (\(v, d) ->
                    let depts = List.map DepartmentTag d.departmentTags
                    in ({ v | departmentTags = depts }, d))

    setSubCatTags = (\(v, d) ->
                      let subCats = List.map SubCategoryTag
                                             d.subCategoryTags
                      in ({ v | subCategoryTags = subCats }, d))

    setSearchTags = (\(v, d) ->
                      let search = List.map SearchTag d.searchTags
                      in ({ v | searchTags = search }, d))

    setName = (\(v, d) ->
                let name_ = d.name
                in ({ v | name = name_ }, d))

    setBrand = (\(v, d) ->
                 let brand_ = d.brand
                 in ({ v | brand = brand_ }, d))

    setVariant = (\(v, d) ->
                   let variant_ = d.variant
                   in ({ v | variant = variant_ }, d))

    setImageThumbnail = (\(v, d) ->
                          let imageThumbnail = d.imageThumbnail
                          in
                            ( { v | imageThumbnail = imageThumbnail }
                            , d
                            ))

    result =
      validateId itemData.id blankSummaryR
        |> Result.andThen
             (validatePrice itemData.id itemData.listPrice)
        |> Result.andThen
             (validateSize itemData.id itemData.size)
        |> Result.andThen
             (validateAvailability itemData.id itemData.availability)
        |> Result.andThen
             (validateDiscount itemData.id itemData.discount)
  in
    case result of
      Err err -> Err err
      Ok val -> 
        let
          (val_, _) =
            setCatTags
            << setDeptTags
            << setSubCatTags
            << setSearchTags
            << setName
            << setImageThumbnail
            << setBrand
            << setVariant
                 <| (val, itemData)
        in Ok <| Summary val_


{-| produce a new SummaryDataR from the given Item
-}
toData : Model -> SummaryDataR
toData item =
  let (Summary record) = item
  in
    { name            = record.name
    , id              = record.id
    , imageThumbnail  = record.imageThumbnail
    , brand           = record.brand
    , variant         = record.variant
    , listPrice       = String.fromFloat record.listPrice
    , size            = sizeToString record.size
    , departmentTags  = List.map tagToData record.departmentTags
    , categoryTags    = List.map tagToData record.categoryTags
    , subCategoryTags = List.map tagToData record.subCategoryTags
    , searchTags      = List.map tagToData record.searchTags
    , availability    = availabilityToStr record.availability
    , discount        = discountToData record.discount
    }


{-| convert an Availability to a string
-}
availabilityToStr : Availability -> String
availabilityToStr availability =
  case availability of
    IN_STOCK    ->  "in_stock"    
    OUT_STOCK   ->  "out_stock"   
    ORDER_ONLY  ->  "order_only"  


{-| produce the data record from the given tag.
-}
tagToData : Tag -> TagR
tagToData tag =
  case tag of
    (DepartmentTag data)   -> data
    (CategoryTag data)     -> data
    (SubCategoryTag data)  -> data
    (SearchTag data)       -> data


{-| produce the data record from the given discount
-}
discountToData : Maybe Discount -> Maybe DiscountDataR
discountToData maybeDiscount =
  case maybeDiscount of
    Nothing -> Nothing
    Just (Discount discountR) -> 
      Just { discount_code = discountR.discount_code
           , name = discountR.name
           , value = String.fromInt discountR.value
           , items = discountR.items
           }


{-| produce the string representation of the given price
-}
priceToString : Float -> String
priceToString price_ =
  let (dollars, cents) = priceToPair price_
      strDollars = String.fromInt dollars
      strCents = String.fromInt cents
  in strDollars ++ "." ++ strCents


{-| ensure the id given to an item is not null (empty string).
On failure produce NullId.
-}
validateId
  : String
  -> SummaryR
  -> Result ValidationErr SummaryR
validateId itemId initialItem =
  if String.length itemId  <= 0
    then Err <| NullId
    else Ok { initialItem | id = itemId }


{-| Take a string representation of a float and try to convert it
to an actual float value. On success, produce the given
SummaryR with the "price" field set to the results of the
convertion. On Failure produce an ValidationErr.
-}
validatePrice
  : String
  -> String
  -> SummaryR
  -> Result ValidationErr SummaryR
validatePrice itemId strPrice initialItem = 
  case String.toFloat strPrice of
    Nothing -> Err <| NaNPrice itemId strPrice
    Just fPrice ->
      if fPrice < 0
        then Err <| NegativePrice itemId strPrice
      else
        Ok { initialItem | listPrice = Round.roundNum 2 fPrice }


{-| produce a new pair from the given price where the first element is
the dollar component and the second element is the cent.

example:

 priceToPair <| 8.99 == (8, 99)
-}
priceToPair : Float -> (Int, Int)
priceToPair fPrice =
  let dollars = floor fPrice
      cents = floor <| (fPrice - (toFloat dollars)) * 100.0
  in (dollars, cents)


{-| Take a string representation of a size and convert it to an actual
Size. On success, produce the given SummaryR with the "size"
field set to the results of the convertion. On failure, produce an
ValidatinErr.
-}
validateSize
  : String
  -> String
  -> SummaryR
  -> Result ValidationErr SummaryR
validateSize itemId strSize initialItem =
  case strToMaybeSize strSize of
    Nothing -> Err <| InvalidSize itemId strSize
    Just size_ -> Ok { initialItem | size = size_ }


{-| Take a string representation of an Availability and try to convert
it to an actual Availability value. On success, produce the given
SummaryR with the "availability" field set to the results of
the convertion. On failure produce an ValidationErr.
-}
validateAvailability
  : String
  -> String
  -> SummaryR
  -> Result ValidationErr SummaryR
validateAvailability itemId strAvailability initialItem = 
  case strToMaybeAvailability strAvailability of
    Nothing -> Err <| InvalidAvailability itemId strAvailability
    Just availability ->
      Ok { initialItem | availability = availability }


{-| Take a simple representation of an Discount (i.e. all fields
are string values), and try to convert it to an actual ItemData value.
On success, produce the given SummaryR with the "discount"
field set to the results of the convertion. On failure produce an
ValidationErr.
-}
validateDiscount
  : String
  -> Maybe DiscountDataR
  -> SummaryR
  -> Result ValidationErr SummaryR
validateDiscount itemId maybeDiscountData initialItem = 
  case maybeDiscountData of
    Nothing -> Ok { initialItem | discount = Nothing }

    Just discountData ->
      let maybeValue = String.toInt discountData.value
      in
        case maybeValue of
          Nothing    ->
            Err <| InvalidDiscount itemId discountData.value "value"
          Just value ->
            Ok { initialItem
               | discount =
                   Just <| newDiscount discountData.discount_code
                                       discountData.name
                                       value
                                       discountData.items
               }


{-| convert a string to Maybe Availability
-}
strToMaybeAvailability : String -> Maybe Availability
strToMaybeAvailability strAvailability =
  case String.toLower (String.trim strAvailability) of
    "in_stock"    -> Just IN_STOCK
    "out_stock"   -> Just OUT_STOCK
    "order_only"  -> Just ORDER_ONLY
    _             -> Nothing


{-| convert a string to Maybe size
-}
strToMaybeSize : String -> Maybe Size
strToMaybeSize strSize =
  case String.trim <| String.toLower strSize of 
    "large"         -> Just LG
    "lg"            -> Just LG
    "xl"            -> Just XL
    "extra large"   -> Just XL
    "extra-large"   -> Just XL
    "xs"            -> Just XS
    "extra small"   -> Just XS
    "extra-small"   -> Just XS
    "small"         -> Just SM
    "sm"            -> Just SM
    "medium"        -> Just M
    "m"             -> Just M
    strGrad         -> strToMaybeGrad strGrad


{-| convert a string to a Grad x Measure or Nothing.
-}
strToMaybeGrad : String -> Maybe Size
strToMaybeGrad strGrad =
  let
    gradFields = String.words strGrad
    maybeMeasure = List.head <| List.drop 1 gradFields
    maybeVal =
      case  List.head gradFields of
        Nothing -> Nothing
        Just strVal ->
          case String.toFloat strVal of
            Nothing -> Nothing
            Just fVal -> Just (Round.roundNum 3 fVal)

  in
    case maybeVal of
      Nothing -> Nothing
      Just val ->
        case maybeMeasure of
          Nothing -> Nothing
          Just measure ->
            case String.toLower measure of
              "ml" -> Just <| Grad val ML
              "mm" -> Just <| Grad val MM
              "cc" -> Just <| Grad val CC
              "mg" -> Just <| Grad val MG
              _    -> Nothing


{-| produce a List of SummaryDataR
-}
setToData : Set -> List SummaryDataR
setToData (Set _ items) =
  List.map (\item -> toData item) items


{-| produce True if the id of both Items are the same
-}
equal : Model -> Model -> Bool
equal item1 item2 = (id item1) == (id item2)


{-| produce the id of the given item
-}
id : Model -> String
id item =
  case item of
    Summary record -> record.id


{-| produce the item name
-}
name : Model -> String
name item =
  case item of
    Summary record -> record.name


brand : Model -> String
brand item =
  case item of
    Summary record -> record.brand


variant : Model -> String
variant item =
  case item of
    Summary record -> record.variant


size : Model -> Size
size item =
  case item of
    Summary record -> record.size


image : Model -> String
image item =
  case item of
    Summary record -> record.imageThumbnail


{-| produce the list price of the given item
-}
listPrice : Model -> Float
listPrice item =
  case item of
    Summary record -> record.listPrice


listFromSet : Set -> List Model
listFromSet (Set _ items) = items


{-| produce the discount sales price of the given item
-}
salePrice : Model -> Float
salePrice item =
  case item of
    Summary record ->
      let listPrice_ = record.listPrice 
          maybeDiscount = record.discount
      in
        case maybeDiscount of
          Nothing -> listPrice_
          Just discount ->
            applyDiscount listPrice_ discount


{-| apply the discount to the price and produce the results.
-}
applyDiscount : Float -> Discount -> Float
applyDiscount listPrice_ discount =
  let (Discount record) = discount
      discountPct_ = record.value
      discountVal =
        listPrice_ * ((toFloat discountPct_)/100)
  in Round.roundNum 2 (listPrice_ - discountVal)


{-| produce the percentage of the given discount
-}
discountPct : Model -> Int
discountPct item =
  case item of
    Summary record ->
      case record.discount of
        Nothing -> 0
        Just (Discount discount) ->
          discount.value


{-| add an item to the set
-}
addToSet : Model -> Set -> Set
addToSet item (Set filters items) =
  Set filters (item::items)


{-| produce a new set from a list list of Item Data
-}
dataListToSet : List SummaryDataR -> Set
dataListToSet lod =
  Set [] <| List.filterMap (\data-> Result.toMaybe (newSummary data)) lod


querySetFor : String -> Set -> Maybe Model
querySetFor itemId (Set _ loi) =
  let query itemId_ loi_ =
        let maybeSubj = List.head loi_
        in
          case maybeSubj of
            Nothing -> Nothing
            Just subj ->
              if (id subj) == itemId_
                then Just subj
                else query itemId_ (List.drop 1 loi_)

  in query itemId loi




-- DUMMY DATA

randomItemName : Int -> String
randomItemName seed =
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


randomImageUrl : Int -> String
randomImageUrl seed =
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


randomBrand : Int ->  String
randomBrand seed =
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


randomVariant : Int -> String
randomVariant seed =
  let mapper x =
        case x of
          0 -> "bag"
          1 -> "can"
          2 -> "green"
          _ -> "red"
      generator = Random.map mapper (Random.int 0 3)
  in Random.step generator (Random.initialSeed seed) |> Tuple.first


randomAvailability : Int -> Availability
randomAvailability seed =
  let mapper x =
        case x of
          1 -> IN_STOCK
          2 -> OUT_STOCK
          _ -> ORDER_ONLY
      generator = Random.map mapper (Random.int 1 3)
  in Random.step generator (Random.initialSeed seed) |> Tuple.first


randomStrAvailability : Int -> String
randomStrAvailability seed =
  let mapper x =
        case x of
          1 -> "IN_STOCK"
          2 -> "OUT_STOCK"
          _ -> "ORDER_ONLY"
      generator = Random.map mapper (Random.int 1 3)
  in Random.step generator (Random.initialSeed seed) |> Tuple.first


randomSize : Int -> Size
randomSize seed =
  let
    mapper constructor value measure  =
      let x = (constructor, value, measure)
      in
        case x of
          (1, value_, measure_) ->
            case measure of
              1 -> Grad value ML
              2 -> Grad value MM
              3 -> Grad value CC
              _ -> Grad value MG
          (2, _, _) -> LG
          (3, _, _) -> XL
          (4, _, _) -> SM
          (5, _, _) -> XS
          (_, _, _) -> M
    generator = Random.map3
                  mapper
                  (Random.int 1 6)
                  (Random.float 0 200)
                  (Random.int 1 4)
  in Random.step generator (Random.initialSeed seed) |> Tuple.first


randomStrSize : Int -> String
randomStrSize seed =
  let
    mapper constructor value measure  =
      let x = (constructor, value, measure)
      in
        case x of
          (1, value_, measure_) ->
            case measure of
              1 -> String.join " " [(String.fromFloat value), "ml"]
              2 -> String.join " " [(String.fromFloat value), "mm"]
              3 -> String.join " " [(String.fromFloat value), "cc"]
              _ -> String.join " " [(String.fromFloat value), "mg"]
          (2, _, _) -> "LG"
          (3, _, _) -> "XL"
          (4, _, _) -> "SM"
          (5, _, _) -> "XS"
          (_, _, _) -> "M"
    generator = Random.map3
                  mapper
                  (Random.int 1 6)
                  (Random.float 1 20000)
                  (Random.int 1 4)
  in Random.step generator (Random.initialSeed seed) |> Tuple.first


randomTag : Int -> { id : String, name : String}
randomTag seed =
  { id   = randomId seed
  , name = randomVariant seed
  }


randomId : Int -> String
randomId seed =
  Random.step UUID.generator (Random.initialSeed seed)
    |> Tuple.first
    |> UUID.toString


randomDiscount : Int -> DiscountDataR
randomDiscount seed =
  { discount_code    = randomId seed
  , name             = randomVariant seed
  , value            = String.fromInt (SRandom.randomInt 1 25 seed)
  , items            = List.map
                         (\i ->
                           let seed_ = seed+i
                           in randomId seed_
                         ) <| List.range 0 8
  }


randomItemSummaryData : Int -> SummaryDataR
randomItemSummaryData seed =
  { name            = randomItemName seed
  , id              = randomId seed
  , imageThumbnail  = randomImageUrl seed
  , brand           = randomBrand seed
  , variant         = randomVariant seed
  , listPrice       = Round.round 2 (SRandom.randomFloat seed)
  , size            = randomStrSize seed
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
  , availability    = randomStrAvailability seed
  , discount        = if SRandom.randomInt 0 1 seed == 1
                        then Just (randomDiscount seed)
                        else Nothing
  }


randomItemSummary : Int -> Model
randomItemSummary seed =
  case newSummary (randomItemSummaryData seed) of
    Err _ -> blankSummary
    Ok brief -> brief


randomSet : Int -> Set
randomSet seed =
  let data = List.map
               (\i ->
                 let seed_ = seed+i
                 in randomItemSummaryData seed_
               ) <| List.range 1 30
  in dataListToSet data

