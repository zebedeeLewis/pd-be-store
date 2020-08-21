module SRandom exposing (..)

import Round
import Random
import UUID


-----------------------------------------------------------------------
-- CONSTANT DEFINITIONS
-----------------------------------------------------------------------



-----------------------------------------------------------------------
-- FUNCTION DEFINITIONS
-----------------------------------------------------------------------

randomFloat : Int -> Float
randomFloat seed =
  Random.step
  (Random.float 1 200)
  (Random.initialSeed seed)
  |> Tuple.first


randomFloat2 : Float -> Float -> Int -> Float
randomFloat2 min max seed =
  Random.step
  (Random.float min max)
  (Random.initialSeed seed)
  |> Tuple.first


randomInt : Int -> Int -> Int -> Int
randomInt min max seed =
  Random.step
  (Random.int min max)
  (Random.initialSeed seed)
  |> Tuple.first



produce_random_id : Int -> String
produce_random_id seed =
  Random.step UUID.generator (Random.initialSeed seed)
    |> Tuple.first
    |> UUID.toString


produce_random_description : Int -> String
produce_random_description seed =
  let mapper x =
        case x of
          0 -> "bag"
          1 -> "can"
          2 -> "green"
          _ -> "red"
      generator = Random.map mapper (Random.int 0 3)
  in Random.step generator (Random.initialSeed seed) |> Tuple.first

