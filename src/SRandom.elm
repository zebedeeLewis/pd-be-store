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

