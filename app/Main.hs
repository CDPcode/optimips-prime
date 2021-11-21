module Main where

import Data.Text    (Text)
import Utils        (normalizeProgram)

import qualified Data.Text              as Text
import qualified Data.Text.IO           as Text.IO
import qualified RedundantStoreRemoval  as RSR

main :: IO ()
main = do 
    program <- Text.IO.getContents
    let program' = normalizeProgram program 
    Text.IO.putStr $ Text.unlines $ RSR.optimize program'
