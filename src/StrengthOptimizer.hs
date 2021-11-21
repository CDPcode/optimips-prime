{-# LANGUAGE OverloadedStrings #-}

module StrengthOptimizer (
    optimize
    ) where

import Data.List    (elemIndex)
import Data.Text    (Text)
import Text.Read    (readMaybe)
import Utils        (checkOperator, getOperands, getOperator)
import qualified Data.Text  as Text
import Data.Functor.Contravariant (Op(getOp))

optimize :: [Text] -> [Text]
optimize = map optimizeInst

optimizeInst :: Text -> Text
optimizeInst inst = case operator of 
    "la"    -> maybeOptimizeLoad inst
    "add"   -> maybeOptimizeAdd inst
    "sub"   -> maybeOptimizeSub inst
    "mul"   -> maybeOptimizeMult inst
    "div"   -> maybeOptimizeDiv inst
    "move"  -> maybeOptimizeMove inst
    _       -> inst
  where
    operator = getOperator inst 

maybeOptimizeLoad :: Text -> Text
maybeOptimizeLoad inst
    | isMult = case maybeImmediate of 
        Nothing -> inst
        Just 0  -> Text.concat ["move ", Text.intercalate ", " [head operands, "$zero"]]
        Just i  ->  Text.concat ["li ", Text.intercalate ", " [head operands, Text.pack $ show i]]
    | otherwise = inst
  where
    isMult = checkOperator "la" inst
    operands = getOperands inst
    maybeImmediate = maybeLast operands >>= (readMaybe . Text.unpack) :: Maybe Int

maybeOptimizeAdd :: Text -> Text
maybeOptimizeAdd inst
    | isMult = case maybeImmediate of 
        Nothing -> inst
        Just 0  -> Text.concat ["move ", Text.intercalate ", " $ init operands]
        Just i  ->  Text.concat ["addi ", Text.intercalate ", " $ init operands ++ [Text.pack $ show i]]
    | otherwise = inst
  where
    isMult = checkOperator "add" inst
    operands = getOperands inst
    maybeImmediate = maybeLast operands >>= (readMaybe . Text.unpack) :: Maybe Int

maybeOptimizeSub :: Text -> Text
maybeOptimizeSub inst
    | isMult = case maybeImmediate of 
        Nothing -> inst
        Just 0  -> Text.concat ["move ", Text.intercalate ", " $ init operands]
        Just i  ->  Text.concat ["subi ", Text.intercalate ", " $ init operands ++ [Text.pack $ show i]]
    | otherwise = inst
  where
    isMult = checkOperator "sub" inst
    operands = getOperands inst
    maybeImmediate = maybeLast operands >>= (readMaybe . Text.unpack) :: Maybe Int

maybeOptimizeMult :: Text -> Text
maybeOptimizeMult inst
    | isMult = case maybeTextPower of 
        Nothing     -> inst
        Just "0"    -> Text.concat ["move ", Text.intercalate ", " $ init operands]
        Just power  -> Text.concat ["sll ", Text.intercalate ", " $ init operands ++ [power]]
    | otherwise = inst
  where
    isMult = checkOperator "mul" inst
    operands = getOperands inst
    maybeImmediate = maybeLast operands >>= (readMaybe . Text.unpack) :: Maybe Int
    maybePower = maybeImmediate >>= getPowerOfTwo
    maybeTextPower = Text.pack . show <$> maybePower

maybeOptimizeDiv :: Text -> Text
maybeOptimizeDiv inst
    | isMult = case maybeTextPower of 
        Nothing     -> inst
        Just "0"    -> Text.concat ["move ", Text.intercalate ", " $ init operands]
        Just power  ->  Text.concat ["sra ", Text.intercalate ", " $ init operands ++ [power]]
    | otherwise = inst
  where
    isMult = checkOperator "div" inst
    operands = getOperands inst
    maybeImmediate = maybeLast operands >>= (readMaybe . Text.unpack) :: Maybe Int
    maybePower = maybeImmediate >>= getPowerOfTwo
    maybeTextPower = Text.pack . show <$> maybePower

maybeOptimizeMove :: Text -> Text
maybeOptimizeMove inst 
    | isRedundantMove inst = ""
    | otherwise = inst

isRedundantMove :: Text -> Bool
isRedundantMove inst = isMove && isRedundant
  where 
    isMove = checkOperator "move" inst
    operands = getOperands inst
    isRedundant = case operands of 
        [op1, op2] -> op1 == op2
        _ -> False

powersOfTwo :: [Int]
powersOfTwo = 1 : map (* 2) powersOfTwo

getPowerOfTwo :: Int -> Maybe Int
getPowerOfTwo n = elemIndex n $ takeWhile (<= n) powersOfTwo

maybeLast :: [a] -> Maybe a
maybeLast [] = Nothing
maybeLast xs = Just $ last xs