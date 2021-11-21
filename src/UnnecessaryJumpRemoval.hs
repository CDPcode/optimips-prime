{-# LANGUAGE OverloadedStrings #-}

module UnnecessaryJumpRemoval(
      optimize
    ) where

import Data.Bifunctor   (first)
import Data.Foldable    (toList)
import Data.Map         (Map)
import Data.Maybe       (isJust, fromJust)
import Data.Text        (Text)
import Data.Sequence    (Seq)
import Utils            (checkOperator, getOperands, isLabel, getOperator, maybeGetLabel)
import qualified Data.Text      as Text
import qualified Data.Map       as Map
import qualified Data.Sequence  as Seq

optimize :: [Text] -> [Text]
optimize program = removeRepeatedLabels $ Text.lines $ Text.unlines $ optimize' programSeq labelMap program 0
  where 
    labelMap = createLabelMap program
    programSeq = Seq.fromList program

optimize' :: Seq Text -> Map Text Int -> [Text] -> Int -> [Text]
optimize' s _ [] _ = toList s
optimize' s m (inst:rest) n 
    | operator == "j" || operator == "b" = case getOperands inst of 
        [] ->  optimize' s m rest (n+1)
        (label:_) -> case Map.lookup label m of
            Nothing -> optimize' s m rest (n+1)
            Just idx -> optimize' (maybeOptimizeJump s label n idx) m rest (n+1)
    | otherwise = optimize' s m rest (n+1)
  where
    operator = getOperator inst

maybeOptimizeJump :: Seq Text -> Text -> Int -> Int -> Seq Text 
maybeOptimizeJump s label i j = case Seq.lookup j s of
    Nothing -> s 
    Just inst -> 
        if isLabel inst 
        then maybeOptimizeJump s label i (j+1)
        else case getOperator inst of
            "j"     -> Seq.update i inst s
            "b"     -> Seq.update i inst s
            "beqz"  -> 
                let aux = Seq.update i (Text.intercalate "\n" [inst, Text.append "j OUT_" label]) s
                in Seq.update j (Text.intercalate "\n" [inst, Text.concat ["OUT_", label, ":"]]) aux
            "bnez"  -> 
                let aux = Seq.update i (Text.intercalate "\n" [inst, Text.append "j OUT_" label]) s
                in Seq.update j (Text.intercalate "\n" [inst, Text.concat ["OUT_", label, ":"]]) aux
            _ -> s

createLabelMap :: [Text] -> Map Text Int
createLabelMap program = Map.fromList $ map (first fromJust) $ filter (isJust . fst) $ zip (map maybeGetLabel program) [1..] 

removeRepeatedLabels :: [Text] -> [Text]
removeRepeatedLabels [] = []
removeRepeatedLabels [x] = [x]
removeRepeatedLabels (x:y:xs) 
    | isLabel x && isLabel y && x == y = x : removeRepeatedLabels xs
    | otherwise = x : removeRepeatedLabels (y:xs)

