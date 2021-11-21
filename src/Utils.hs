{-# LANGUAGE OverloadedStrings #-}

module Utils (
      removeComment
    , checkOperator
    , normalizeLine
    , getOperands
    , getOperator
    , normalizeProgram
    ) where

import Data.Text    (Text)
import qualified Data.Text  as Text

normalizeProgram :: Text -> [Text]
normalizeProgram = filter (not . Text.null) . map normalizeLine . Text.lines

removeComment :: Text -> Text
removeComment = Text.takeWhile (/= '#')

normalizeLine :: Text -> Text 
normalizeLine = Text.strip . removeComment

isLabel :: Text -> Bool
isLabel t = case Text.strip t of
    "" -> False
    t' -> Text.last t' == ':'

maybeGetLabel :: Text -> Maybe Text
maybeGetLabel t  
    | isLabel t = Just $ Text.strip $ Text.takeWhile (/= ':') t
    | otherwise = Nothing

checkOperator :: Text -> Text -> Bool
checkOperator _ "" = False
checkOperator op inst = head (Text.words inst) == op

getOperands :: Text -> [Text]
getOperands "" = []
getOperands inst = Text.splitOn "," $ Text.concat $ tail $ Text.words inst

getOperator :: Text -> Text
getOperator "" = ""
getOperator xs = head $ Text.words xs