module Main where

import Data.Text    (Text)
import Utils        (normalizeProgram)

import qualified Data.Text              as Text
import qualified Data.Text.IO           as Text.IO
import qualified RedundantStoreRemoval  as RSR
import qualified StrengthOptimizer      as Strength

main :: IO ()
main = do 
    program <- Text.IO.getContents
    let program' = normalizeProgram program 
    let optimize = RSR.optimize . Strength.optimize 
    let optimized = optimize program'
    Text.IO.putStr $ Text.unlines $ filter (not . Text.null) optimized
