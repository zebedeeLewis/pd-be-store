module ItemSummaryTest exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)

import ItemSummary


-----------------------------------------------------------------------
-- CONSTANTS DATA
-----------------------------------------------------------------------

it = test



-----------------------------------------------------------------------
-- SAMPLE DATA
-----------------------------------------------------------------------

itemSummaryData : ItemSummary.ItemSummaryDataRecord
itemSummaryData =
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


-----------------------------------------------------------------------
-- TESTS
-----------------------------------------------------------------------

newItemSummary =
  describe "newItemSummary"
    [ it ( "produces InvalidItemData on \"price\" field on NaN " ++
           "price data")
         <| \_ ->
              Expect.equal
                ( ItemSummary.newItemSummary
                    { itemSummaryData | price = "$123.30" } )
                ( Err
                     <| ItemSummary.InvalidItemData
                          itemSummaryData.id
                          "price" )

    , it ( "produces InvalidItemData on \"size\" field on invalid " ++
           "size data")
         <| \_ ->
              Expect.equal
                ( ItemSummary.newItemSummary
                    { itemSummaryData | size = "invalid size" } )
                ( Err
                     <| ItemSummary.InvalidItemData
                          itemSummaryData.id
                          "size" )

    , it ( "produces InvalidItemData on \"availability\" field on " ++
           "invalid availability data")
         <| \_ ->
              Expect.equal
                ( ItemSummary.newItemSummary
                    { itemSummaryData | availability = "invalid" } )
                ( Err
                     <| ItemSummary.InvalidItemData
                          itemSummaryData.id
                          "availability" )
    ]


strToMaybeSize =
  describe "strToMaybeSize"
    [ it ("produces nothing when given a string that cannot be " ++
          "converted .")
        <| \_ ->
             Expect.equal
               (ItemSummary.strToMaybeSize "random string")
               Nothing

    , it ("produces LG when given the string \"large\". Match is " ++
          " case-insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal
                   (ItemSummary.strToMaybeSize "large")
               , Expect.equal
                   (ItemSummary.strToMaybeSize "LARGE")
               , Expect.equal
                   (ItemSummary.strToMaybeSize "LaRgE")
               ]
             (Just ItemSummary.LG)

    , it ("produces LG when given the string \"lg\". Match is " ++
          " case-insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal
                   (ItemSummary.strToMaybeSize "lg")
               , Expect.equal
                   (ItemSummary.strToMaybeSize "LG")
               , Expect.equal
                   (ItemSummary.strToMaybeSize "Lg")
               ]
             (Just ItemSummary.LG)

    , it ("produces XL when given the string \"extra-large\", " ++
          "\"extra large\", or \"xl\". Case insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal
                   (ItemSummary.strToMaybeSize "EXTRA-laRge")
               , Expect.equal
                   (ItemSummary.strToMaybeSize "extra LaRge")
               , Expect.equal
                   (ItemSummary.strToMaybeSize "xl")
               ]
             (Just ItemSummary.XL)

    , it ("produces XS when given the string \"extra-small\", " ++
          "\"extra small\", or \"xs\". Case insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal
                   (ItemSummary.strToMaybeSize "EXTRA-smAll")
               , Expect.equal
                   (ItemSummary.strToMaybeSize "extra SmAll")
               , Expect.equal
                   (ItemSummary.strToMaybeSize "xs")
               ]
             (Just ItemSummary.XS)

    , it ("produces SM when given the string \"small\" or \"sm\". " ++
          "Case insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal
                   (ItemSummary.strToMaybeSize "smAll")
               , Expect.equal
                   (ItemSummary.strToMaybeSize "SMALL")
               ]
             (Just ItemSummary.SM)

    , it ("produces M when given the string \"medium\" or \"m\". " ++
          "Case insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal
                   (ItemSummary.strToMaybeSize "Medium")
               , Expect.equal
                   (ItemSummary.strToMaybeSize "MEDIUM")
               , Expect.equal
                   (ItemSummary.strToMaybeSize "MEdIuM")
               ]
             (Just ItemSummary.M)
    ]


strToMaybeGrad =
  describe "strToMaybeGrad"
    [ it ("produces nothing when given a string that cannot be " ++
          "converted.")
        <| \_ ->
             Expect.equal
               (ItemSummary.strToMaybeGrad "random string")
               Nothing

    , it ("produces Grad x ML when given a string consisting of " ++
          "a number and the string \"ml\" case-insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal (ItemSummary.strToMaybeGrad "15.2 ml")
               , Expect.equal (ItemSummary.strToMaybeGrad "15.2 Ml")
               , Expect.equal (ItemSummary.strToMaybeGrad "15.2 mL")
               ]
               (Just <| ItemSummary.Grad 15.2 ItemSummary.ML)

    , it ("produces Grad x MM when given a string consisting of " ++
          "a number and the string \"mm\" case-insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal (ItemSummary.strToMaybeGrad "15.2 mm")
               , Expect.equal (ItemSummary.strToMaybeGrad "15.2 Mm")
               , Expect.equal (ItemSummary.strToMaybeGrad "15.2 mM")
               ]
               (Just <| ItemSummary.Grad 15.2 ItemSummary.MM)

    , it ("produces Grad x CC when given a string consisting of " ++
          "a number and the string \"cc\" case-insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal (ItemSummary.strToMaybeGrad "15.2 cc")
               , Expect.equal (ItemSummary.strToMaybeGrad "15.2 Cc")
               , Expect.equal (ItemSummary.strToMaybeGrad "15.2 cC")
               ]
               (Just <| ItemSummary.Grad 15.2 ItemSummary.CC)

    , it ("produces Grad x MG when given a string consisting of " ++
          "a number and the string \"mg\" case-insensitive.")
        <| \_ ->
             Expect.all
               [ Expect.equal (ItemSummary.strToMaybeGrad "15.2 mg")
               , Expect.equal (ItemSummary.strToMaybeGrad "15.2 Mg")
               , Expect.equal (ItemSummary.strToMaybeGrad "15.2 mG")
               ]
               (Just <| ItemSummary.Grad 15.2 ItemSummary.MG)
    ]
