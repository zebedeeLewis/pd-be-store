module ItemSummary exposing
  ( ItemSummary
  , InvalidItemData(..)
  , ItemSummaryDataRecord
  , newItemSummary
  , filterByDepartment
  , newDeptTag
  , newCatTag
  , newSubCatTag
  , newSearchTag
  , newItemDiscount
  )


import Time


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


blankItemSummaryRecord : ItemSummaryRecord
blankItemSummaryRecord =
  { name            = ""
  , id              = ""
  , imageThumbnail  = ""
  , brand           = ""
  , variant         = ""
  , price           = 0.0
  , size            = LG
  , departmentTags  = []
  , categoryTags    = []
  , subCategoryTags = []
  , searchTags      = []
  , availability    = OUT_STOCK
  , discount        = Nothing
  }



-----------------------------------------------------------------------
-- DATA DEFINITIONS
-----------------------------------------------------------------------

{-| represents a summary descriptions of a single type of inventory
item.

**departmentTags:** a collection of tags, each representing a department
the item should be in.

**categoryTags:** A collections of tags, each representing a department
category the item should be in. This serves to sub-devides individual
departments.

**kubCategoryTags:** A collection of tags, each representing a
department sub-category the item should be in. This serves to further
sub-devide individual departments.

**searchTags:** A collection of tags, these are tags used to aid in
searching for this item.

example:
  deptTag = newDeptTag "UID123" "whole foods"
  deptTag2 = newDeptTag "UID456" "foods"

  catTag = newCatTag "UIDC123" "meats"
  catTag2 = newCatTag "UIDC456" "vegan"
  subCatTag = newSubCatTag "UIDSC123" "poultry"
  subCatTag2 = newSubCatTag "UIDSC456" "organic"

  searchTag = newSearchTag "UIDS123" "chicken"

  discount =
    newItemDiscount "UXDS9y3" "seafood giveaway" 15.0 ["CHKCCS1233"]

  itemSummary1 : ItemSummaryRecord
  itemSummary1 =
    { name            = "chicken legs"
    , id              = "CHKCCS1233"
    , imageThumbnail  = "https://www.example.com/chicken.jpg"
    , brand           = "caribbean chicken"
    , variant         = "bag"
    , price           = 15.93
    , size            = Grad 1000.5 MG
    , departmentTags  = [ deptTag
                        , deptTag2
                        ]
    , categoryTags    = [ catTag
                        , catTag2
                        ]
    , subCategoryTags = [ subCatTag
                        , subCatTag2
                        ]
    , searchTags      = [ searchTag ]
    , availability    = IN_STOCK
    , discount        = Just discount
    }
-}
type alias ItemSummaryRecord =
  { name            : String
  , id              : String
  , imageThumbnail  : String
  , brand           : String
  , variant         : String
  , price           : Float
  , size            : Size
  , departmentTags  : List Tag
  , categoryTags    : List Tag
  , subCategoryTags : List Tag
  , searchTags      : List Tag
  , availability    : Availability
  , discount        : Maybe ItemDiscountRecord
  }


{-| Represents the information necessary to build a new
ItemSummaryRecord. All fields hold simple string data or "subrecords".

All fields match one to one with the fields in ItemSummaryRecord.

example:
  data =
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

-}
type alias ItemSummaryDataRecord =
  { name            : String
  , id              : String
  , imageThumbnail  : String
  , brand           : String
  , variant         : String
  , price           : String
  , size            : String
  , departmentTags  : List { id : String, name : String }
  , categoryTags    : List { id : String, name : String }
  , subCategoryTags : List { id : String, name : String }
  , searchTags      : List { id : String, name : String }
  , availability    : String
  , discount        : { discount_code : String
                      , name          : String
                      , value         : String
                      , iems          : List String
                      }
  }


{-| Represents a short description of an item (i.e. an inventory item)
used to display a short summary of the item to the user.
-}
type ItemSummary 
  = ItemSummary ItemSummaryRecord


{-| If a user of this module attempts to create a new item with
invalid data, that will result in an InvalidItemData. The first
field of InvalidItemData is the id of the data item used in the
attempt, the second is the name of the errant field.
-}
type InvalidItemData = InvalidItemData String String


type ResultSet = ResultSet (List ItemSummary)


type CategorizedResultSet =
  CategorizedResultSet Tag (List ItemSummary)


{-| Represents a discount that is automatically applied to a select
item.

**discount_code:** unique identifier for the given discount
**name:** user friendly name for the discount
**value:** percent value of the discount.
**items:** the ids for the items this discount applies to.

example:

itemDiscount : ItemDiscount
itemDiscount =
  { discount_code = "UXDS9y3"
  , name          = "seafood giveaway"
  , value         = 15
  , iems          = ["CHKCCS1233"]
  }

-}
type alias ItemDiscountRecord =
  { discount_code    : String
  , name             : String
  , value            : Float
  , items            : List String
  }


type ItemDiscount = ItemDiscount ItemDiscountRecord


{-| Represents a discount that the user has the option to apply. Once
applied the discount will take effect on a select set of items.

Has the exact set of fields as ItemDiscount along with the following
additional field:

**expirationTime:** the current time passes this expiration time, then
the discount is no longer valid.

**startingBalance:** user discounts cannot be applied beyond a certain
dollar amount. This represents the balance to that dollar cap before
the discount is applied.

**finalBalance:** represents the balance to the dollar cap after the
discount is applied.

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

-}
type alias UserDiscountRecord =
  { discount_code    : String
  , name             : String
  , value            : Float
  , items            : List String
  , expirationTime   : Time.Posix
  , startingBalance  : Float
  , finalBalance     : Float
  }


type UserDiscount = UserDiscount UserDiscountRecord


{-|
  represents the availability of inventory items of a given type.

    IN_STOCK   - represents a type of item that is currently in stock.

    OUT_STOCK  - represents a type of item that is currently out of
                 stock.
    ORDER_ONLY - represents a type of item that is available on a
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


{-|
  represents the basic unit of measurement for length, volume and
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
  | CM3
  | MG


{-|
  represents the size of an item, this can be an exact measurement
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


{-|
  represents a single tag used to categorize a group of items.

  examples: 

  tag1 : Entity.TagRecord
  tag1 =
    { id   = "UID4123"
    , name = "foods"
    }

-}
type alias TagRecord =
  { id    : String
  , name  : String
  }


type Tag
  = DepartmentTag TagRecord
  | CategoryTag TagRecord
  | SubCategoryTag TagRecord
  | SearchTag TagRecord


{-|
  represents an item added to a shopping cart as well as how many
  individual items of that type is added.

  examples:

  shoppingCartEntry1 =
    { item      = itemSummary1
    , quantity  = 2
    }
-}
type alias ShoppingCartEntryM =
  { item      : ItemSummaryRecord
  , quantity  : Int
  }


type alias ShoppingCart = List ShoppingCartEntryM


-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

{-|
  produce a list of all Entity with the given tagName.
-}
filterByDepartment
  : TagRecord
  -> List ItemSummaryRecord
  -> List ItemSummaryRecord
filterByDepartment department items =
  -- List.filter (\item -> 
  --   List.member department item.departmentTags
  -- )
  items


{-|
  produce the string representation of an Size
-}
itemSizeToString : ItemSummaryRecord -> String
itemSizeToString item =
  sizeToString item.size


sizeToString : Size -> String
sizeToString size =
  case size of
    LG -> "LG"
    XL -> "XL"
    SM -> "SM"
    XS -> "XS"
    M  -> "M"
    Grad value measure ->
      case measure of
        ML  ->
          let
            val =
              if value > gallon
                then value/gallon
              else if value > litre
                then value/litre
              else value

            rdMeasure =
              if value > gallon
                then "gal"
              else if value > litre
                then "L"
              else "mL"
          in
            (String.fromFloat val) ++ rdMeasure 

        CM3 ->
          let
            val =
              if value > cubicMetre
                then value/cubicMetre
                else value

            rdMeasure =
              if val > cubicMetre
                then "cc"
                else "m cube"
          in
            (String.fromFloat val) ++ rdMeasure

        MG ->
          let
            val =
              if value > kilogram
                then value/kilogram
              else if value > gram
                then value/gram
              else value

            rdMeasure =
              if value > kilogram
                then "kg"
              else if value > gram
                then "g"
              else "mg"
          in
            (String.fromFloat val) ++ rdMeasure
        MM ->
          let
            val =
              if value > metre
                then value/metre
              else if value > centimetre
                then value/centimetre
              else value
            rdMeasure =
              if value > metre
                then "m"
              else if value > centimetre
                then "cm"
              else "mm"
          in
            (String.fromFloat val) ++ rdMeasure


getTagRecord : Tag -> TagRecord
getTagRecord tag =
  case tag of
    DepartmentTag tag_ -> tag_
    CategoryTag tag_ -> tag_
    SubCategoryTag tag_ -> tag_
    SearchTag tag_ -> tag_


{-| produce a new department tag from the given tuple

example:

  tag = newDeptTag "UID123" "foods"

-}
newDeptTag : String -> String -> Tag
newDeptTag id name = DepartmentTag { id = id, name = name }


{-| produce a new category tag from the given tuple

example:

  tag = newCatTag "UID123" "foods"

-}
newCatTag : String -> String -> Tag
newCatTag id name = CategoryTag { id = id, name = name }


{-| produce a new sub-category tag from the given tuple

example:

  tag = newSubCatTag "UID123" "foods"

-}
newSubCatTag : String -> String -> Tag
newSubCatTag id name = SubCategoryTag { id = id, name = name }


{-| produce a new search tag from the given tuple

example:

  tag = newSearchTag "UID123" "foods"

-}
newSearchTag : String -> String -> Tag
newSearchTag id name = SearchTag { id = id, name = name }


{-| produce a new ItemDiscount from the given tuple

example:

  discount = 
    ewItemDiscount "UXDS9y3" "seafood giveaway" 15.0 ["CHKCCS1233"]

-}
newItemDiscount
  : String
  -> String
  -> Float
  -> List String
  -> ItemDiscount
newItemDiscount  code name value items =
  ItemDiscount { discount_code = code
               , name          = name
               , value         = value
               , items         = items
               }


{-| Validate the given input data and produce a new ItemSummary
from the given data record or InvalidItemData if any of the data
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

  newItemSummary itemData ==
    ItemSummary
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
      , discount        = ItemDiscount
                            { discount_code = "UXDS9y3"
                            , name          = "seafood giveaway"
                            , value         = "15"
                            , iems          = ["CHKCCS1233"]
                            }
      }

-}
newItemSummary
  : ItemSummaryDataRecord
  -> Result InvalidItemData ItemSummary
newItemSummary itemData =
  let
    result =
      validatePrice itemData.id itemData.price blankItemSummaryRecord
        |> Result.andThen
             (validateSize itemData.id itemData.size)
  in
    case result of
      Err err -> Err err
      Ok val ->  Ok <| ItemSummary val


{-| Take a string representation of a float and try to convert it
to an actual float value. On success, produce the given
ItemSummaryRecord with the "price" field set to the results of the
convertion. On Failure produce an InvalidItemData on the "price" field.

-}
validatePrice
  : String
  -> String
  -> ItemSummaryRecord
  -> Result InvalidItemData ItemSummaryRecord
validatePrice itemId strPrice initialItem = 
  case String.toFloat strPrice of
    Nothing -> Err <| InvalidItemData itemId "price" 
    Just price -> Ok { initialItem | price = price }


{-| Take a string representation of a size and convert it to an actual
Size. On success, produce the given ItemSummaryRecord with the "size"
field set to the results of the convertion. On failure, produce an
InvalidItemData on the "size" field.
TODO!!!
-}
validateSize
  : String
  -> String
  -> ItemSummaryRecord
  -> Result InvalidItemData ItemSummaryRecord
validateSize itemId strSize initialItem =
  Err <| InvalidItemData itemId "size" 


{-| take a string representation of an Availability and try to convert
it to an actual Availability value.
TODO!!!
-}
validateAvailability
  : String
  -> ItemSummaryRecord
  -> Result InvalidItemData ItemSummaryRecord
validateAvailability strAvailability initialItem = 
  Err <| InvalidItemData "test" "availability"


{-| convert a string to Maybe size
TODO!!!
-}
stringToMaybeSize : String -> Maybe Size
stringToMaybeSize strSize = Nothing


{-| convert a string to Maybe Availability
TODO!!!
-}
stringToMaybeAvailability : String -> Maybe Availability
stringToMaybeAvailability strAvailability = Nothing
