module DummyItem exposing (..)

import Random
import UUID

import Item


-----------------------------------------------------------------------
-- CONSTANT DEFINITIONS
-----------------------------------------------------------------------



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

randomItemName : Int -> String
randomItemName seed =
  let mapper x =
        case x of
          0 -> "chicken legs"
          1 -> "tortialla chips"
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


randomSize : Int -> Item.Size
randomSize seed =
  let
    mapper constructor value measure  =
      let x = (constructor, value, measure)
      in
        case x of
          (1, value_, measure_) ->
            case measure of
              1 -> Item.Grad value Item.ML
              2 -> Item.Grad value Item.MM
              3 -> Item.Grad value Item.CC
              _ -> Item.Grad value Item.MG
          (2, _, _) -> Item.LG
          (3, _, _) -> Item.XL
          (4, _, _) -> Item.SM
          (5, _, _) -> Item.XS
          (_, _, _) -> Item.M
    generator = Random.map3
                  mapper
                  (Random.int 1 6)
                  (Random.float 0 200)
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


randomFloat : Int -> Float
randomFloat seed =
  Random.step
  (Random.float 1 200)
  (Random.initialSeed seed)
  |> Tuple.first


randomDiscount : Int -> Item.DiscountDataR
randomDiscount seed =
  { discount_code    = randomId seed
  , name             = randomVariant seed
  , value            = String.fromFloat (randomFloat seed)
  , items            = List.map
                         (\i ->
                           let seed_ = seed+i
                           in randomId seed_
                         ) <| List.range 0 8
  }


randomItemBriefData : Int -> Item.BriefDataR
randomItemBriefData seed =
  { name            = randomItemName seed
  , id              = randomId seed
  , imageThumbnail  = "https://www.example.com/chicken.jpg"
  , brand           = randomBrand seed
  , variant         = randomVariant seed
  , listPrice       = String.fromFloat (randomFloat seed)
  , size            = Item.sizeToString (randomSize seed)
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
  , availability    = ""
  , discount        = Nothing
  }

