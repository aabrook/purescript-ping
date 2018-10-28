module Speedtest where

import Prelude

import Effect.Console (log)
import Effect

import Control.Monad.Cont (ContT(..), runContT)

import Data.Array ((!!), last, take)
import Data.Maybe (Maybe(..), maybe)
import Data.String (Pattern(..), split, indexOf)
import Data.Foldable (foldl)

import Node.ChildProcess (ExecOptions, ExecResult(..), defaultExecOptions, exec, stdout)
import Node.Stream (onData)

lines :: String -> Array String
lines = split (Pattern "\\n")

words :: String -> Array String
words = split (Pattern " ")

newtype SpeedtestResult = SpeedtestResult
  { download :: String
  , upload :: String
  , host :: String
  , source :: String
  }

defaultSpeedtest = {
  download: ""
  , upload: ""
  , host: ""
  , source: ""
  }

is :: forall a. Maybe a -> Boolean
is = maybe false (const true)

addToRecord rec row
  | (is $ indexOf (Pattern "Download") row) = rec { download = row }
  | (is $ indexOf (Pattern "Hosted") row) = rec { host = row }
  | (is $ indexOf (Pattern "Testing from") row) = rec { source = row }
  | (is $ indexOf (Pattern "Upload") row) = rec { upload = row }
  | otherwise = rec

instance showSpeedtest :: Show SpeedtestResult where
  show (SpeedtestResult { download, upload, host, source }) = "{\"download\": \"" <> download <> "\",\"upload\": \"" <> upload <>  "\", \"host\": \"" <> host <> "\", \"source\": \"" <> source <> "\"}"

--resultToReply :: ExecResult -> Maybe SpeedtestResult
resultToReply { stdout } = do
    show stdout # lines #
      foldl addToRecord defaultSpeedtest # SpeedtestResult


-- contSpeedtest :: ContT Unit Effect (Effect)
contSpeedtest = ContT (\f -> do
  _ <- exec "speedtest-cli" defaultExecOptions (f <<< resultToReply)
  pure unit
  )

