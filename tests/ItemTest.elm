module ItemTest exposing (..)

{-| To enable tests:

1. uncomment all the commented out lines below
2. comment out all the "Production Exports" in the Item module
3. uncomment the "Test Exports" in the Item module
-}

import Expect exposing (Expectation)
import Test exposing (..)

import Item


-------------------------------------------------------------------------
-- CONSTANTS DATA
-------------------------------------------------------------------------

it = test



-------------------------------------------------------------------------
-- SAMPLE DATA
-------------------------------------------------------------------------

-- enable = todo "Enable Item Tests"

itemBriefData : Item.BriefDataR
itemBriefData =
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
  , discount        = Just { discount_code = "UXDS9y3"
                           , name          = "seafood giveaway"
                           , value         = "15.0"
                           , items         = ["CHKCCS1233"]
                           }
  }

itemBriefR : Item.BriefR
itemBriefR =
      { name            = "chicken legs"
      , id              = "CHKCCS1233"
      , imageThumbnail  = "https://www.example.com/chicken.jpg"
      , brand           = "caribbean chicken"
      , variant         = "bag"
      , price           = Item.Price 15 93
      , size            = Item.Grad 1000.5 Item.MG
      , departmentTags  = [ Item.DepartmentTag
                              { id = "UID789"
                              , name = "deptTag"
                              }
                          ]
      , categoryTags    = [ Item.CategoryTag
                              { id = "UID456"
                              , name = "catTag"
                              }
                          ]
      , subCategoryTags = [ Item.SubCategoryTag
                              { id   = "UID4123"
                              , name = "subCatTag"
                              }
                          ]
      , searchTags      = [ Item.SearchTag
                              { id   = "UID333"
                              , name = "searchTag"
                              }
                          ]
      , availability    = Item.IN_STOCK
      , discount        = Just <| Item.Discount
                            { discount_code = "UXDS9y3"
                            , name          = "seafood giveaway"
                            , value         = 15.0
                            , items         = ["CHKCCS1233"]
                            }
      }


-------------------------------------------------------------------------
-- TESTS
-------------------------------------------------------------------------

toData =
  describe "toData"
    [ it "produces the DataR representation of the given item."
      (\_->
        let expected = itemBriefData
            item = Item.Brief itemBriefR
            actual = Item.toData item
        in Expect.equal expected actual
      )
    ]

new =
  describe "new"
    [ it ( "produces NaNPrice when given price data that is not a " ++
           "number.")
         <| \_ ->
              let newPriceData = "$123.30"
              in
                Expect.equal
                  ( Item.new
                      { itemBriefData | price = newPriceData } )
                  ( Err
                       <| Item.NaNPrice
                            itemBriefData.id newPriceData )

    , it ( "produces NegativePrice when given price data that is " ++
           "less thant 0.")
         <| \_ ->
              let newPriceData = "-123.30"
              in
                Expect.equal
                  ( Item.new
                      { itemBriefData | price = newPriceData } )
                  ( Err
                       <| Item.NegativePrice
                            itemBriefData.id newPriceData )

    , it ( "produces InvalidSize when given invalid size data")
         <| \_ ->
              let newSizeData = "invalid size"
              in
                Expect.equal
                  ( Item.new
                      { itemBriefData | size = newSizeData } )
                  ( Err
                       <| Item.InvalidSize
                            itemBriefData.id newSizeData )

    , it ( "produces InvalidAvailability when given invalid " ++
           "availability data")
         <| \_ ->
              let newData = "invalid"
              in
                Expect.equal
                  ( Item.new
                      { itemBriefData | availability = newData } )
                  ( Err
                       <| Item.InvalidAvailability
                            itemBriefData.id newData )

    , it ( "produces InvalidDiscount on \"value\" sub-field when " ++
           "given an invalid discount value data")
         <| \_ ->
                 
              let newData = "invalid"
                  discount =
                    case itemBriefData.discount of
                      Nothing -> Nothing
                      Just discountData ->
                        Just { discountData | value = newData }
              in
                Expect.equal
                  ( Item.new { itemBriefData | discount = discount } )
                  ( Err
                       <| Item.InvalidDiscount
                            itemBriefData.id newData "value" )

    , it ( "produces a new Item when given a valid " ++
           "BriefDataR")
         <| \_ ->
              Expect.equal
                ( Item.new itemBriefData )
                ( Ok <| Item.Brief itemBriefR )

    , it ( "produces NullId when given id data that is and empty " ++
           "string.")
         <| \_ ->
              let newData = "invalid"
              in
                Expect.equal
                  ( Item.new
                      { itemBriefData | id = "" } )
                  ( Err Item.NullId  )
    ]


strToMaybeSize =
  describe "strToMaybeSize"
    [ it ("produces nothing when given a string that cannot be " ++
          "converted .")
        <| \_ ->
             Expect.equal
               (Item.strToMaybeSize "random string")
               Nothing

    , it ("produces LG when given the string \"large\". Match is " ++
          " case-insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal
                   (Item.strToMaybeSize "large")
               , Expect.equal
                   (Item.strToMaybeSize "LARGE")
               , Expect.equal
                   (Item.strToMaybeSize "LaRgE")
               ]
             (Just Item.LG)

    , it ("produces LG when given the string \"lg\". Match is " ++
          " case-insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal
                   (Item.strToMaybeSize "lg")
               , Expect.equal
                   (Item.strToMaybeSize "LG")
               , Expect.equal
                   (Item.strToMaybeSize "Lg")
               ]
             (Just Item.LG)

    , it ("produces XL when given the string \"extra-large\", " ++
          "\"extra large\", or \"xl\". Case insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal
                   (Item.strToMaybeSize "EXTRA-laRge")
               , Expect.equal
                   (Item.strToMaybeSize "extra LaRge")
               , Expect.equal
                   (Item.strToMaybeSize "xl")
               ]
             (Just Item.XL)

    , it ("produces XS when given the string \"extra-small\", " ++
          "\"extra small\", or \"xs\". Case insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal
                   (Item.strToMaybeSize "EXTRA-smAll")
               , Expect.equal
                   (Item.strToMaybeSize "extra SmAll")
               , Expect.equal
                   (Item.strToMaybeSize "xs")
               ]
             (Just Item.XS)

    , it ("produces SM when given the string \"small\" or \"sm\". " ++
          "Case insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal
                   (Item.strToMaybeSize "smAll")
               , Expect.equal
                   (Item.strToMaybeSize "SMALL")
               ]
             (Just Item.SM)

    , it ("produces M when given the string \"medium\" or \"m\". " ++
          "Case insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal
                   (Item.strToMaybeSize "Medium")
               , Expect.equal
                   (Item.strToMaybeSize "MEDIUM")
               , Expect.equal
                   (Item.strToMaybeSize "MEdIuM")
               ]
             (Just Item.M)
    ]


strToMaybeGrad =
  describe "strToMaybeGrad"
    [ it ("produces nothing when given a string that cannot be " ++
          "converted.")
        <| \_ ->
             Expect.equal
               (Item.strToMaybeGrad "random string")
               Nothing

    , it ("produces Grad x ML when given a string consisting of " ++
          "a number and the string \"ml\" case-insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal (Item.strToMaybeGrad "15.2 ml")
               , Expect.equal (Item.strToMaybeGrad "15.2 Ml")
               , Expect.equal (Item.strToMaybeGrad "15.2 mL")
               ]
               (Just <| Item.Grad 15.2 Item.ML)

    , it ("produces Grad x MM when given a string consisting of " ++
          "a number and the string \"mm\" case-insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal (Item.strToMaybeGrad "15.2 mm")
               , Expect.equal (Item.strToMaybeGrad "15.2 Mm")
               , Expect.equal (Item.strToMaybeGrad "15.2 mM")
               ]
               (Just <| Item.Grad 15.2 Item.MM)

    , it ("produces Grad x CC when given a string consisting of " ++
          "a number and the string \"cc\" case-insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal (Item.strToMaybeGrad "15.2 cc")
               , Expect.equal (Item.strToMaybeGrad "15.2 Cc")
               , Expect.equal (Item.strToMaybeGrad "15.2 cC")
               ]
               (Just <| Item.Grad 15.2 Item.CC)

    , it ("produces Grad x MG when given a string consisting of " ++
          "a number and the string \"mg\" case-insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal (Item.strToMaybeGrad "15.2 mg")
               , Expect.equal (Item.strToMaybeGrad "15.2 Mg")
               , Expect.equal (Item.strToMaybeGrad "15.2 mG")
               ]
               (Just <| Item.Grad 15.2 Item.MG)
    ]


strToMaybeAvailability =
  describe "strToMaybeAvailability"
    [ it ("produces nothing when given a string that cannot be " ++
          "converted.")
        <| \_ ->
             Expect.equal
               (Item.strToMaybeAvailability "random string")
               Nothing

    , it ("produces IN_STOCK when given string \"in_stock\" " ++
          "case-insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal
                   (Item.strToMaybeAvailability "in_stock")
               , Expect.equal
                   (Item.strToMaybeAvailability "iN_sTOck")
               , Expect.equal
                   (Item.strToMaybeAvailability "IN_STOCK")
               ]
               (Just Item.IN_STOCK)

    , it ("produces OUT_STOCK when given string \"out_stock\" " ++
          "case-insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal
                   (Item.strToMaybeAvailability "out_stock")
               , Expect.equal
                   (Item.strToMaybeAvailability "oUt_sTOck")
               , Expect.equal
                   (Item.strToMaybeAvailability "OUT_STOCK")
               ]
               (Just Item.OUT_STOCK)

    , it ("produces ORDER_ONLY when given string \"order_only\" " ++
          "case-insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal
                   (Item.strToMaybeAvailability "order_only")
               , Expect.equal
                   (Item.strToMaybeAvailability "oRdeR_oNLy")
               , Expect.equal
                   (Item.strToMaybeAvailability "ORDER_ONLY")
               ]
               (Just Item.ORDER_ONLY)
    ]


