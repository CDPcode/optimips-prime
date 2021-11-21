{-# LANGUAGE OverloadedStrings #-}

module RedundantStoreRemoval (
    optimize
    ) where

import Data.Text    (Text)
import Utils        (checkOperator, getOperands)
import qualified Data.Text  as Text

optimize :: [Text] -> [Text]
optimize (ld:st:xs) = maybeRemoveStore ld st ++ xs
optimize xs = xs

maybeRemoveStore :: Text -> Text -> [Text]
maybeRemoveStore ldInst stInst
    | isLoad && isStore && sameOperands = [ldInst]
    | otherwise  = [ldInst, stInst]
  where
    isLoad = checkOperator "lw" ldInst
    isStore = checkOperator "sw" stInst
    loadOperands = getOperands ldInst
    storeOperands = getOperands stInst
    sameOperands = loadOperands == storeOperands
