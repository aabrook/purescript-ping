module Ping where

import Prelude

import Effect.Console (log)
import Effect

import Control.Monad.Cont (ContT(..), runContT)

import Data.Array ((!!), last, take)
import Data.Maybe (Maybe(..), maybe)
import Data.String (Pattern(..), split)

import Node.ChildProcess (ExecOptions, ExecResult(..), defaultExecOptions, exec, stdout)
import Node.Stream (onData)

newtype PingReply = PingReply
  { ttl :: String
  , time :: String
  }

instance showPing :: Show PingReply where
  show (PingReply { ttl, time }) = "{\"time\": " <> time <> "\",\"ttl\": \"" <> ttl <> "\"}"

resultToReply :: ExecResult -> Maybe PingReply
resultToReply { stdout } = do
  row <- pure $ split (Pattern "\\n") $ show stdout
  reply <- row !! 1
  res <- last $ split (Pattern ": ") reply
  response <- pure $ take 4 $ split (Pattern " ") res
  case response of
    [_cmp, ttl, time, ms] -> Just (PingReply {ttl, time: time <> ms})
    _ -> Nothing

contPing :: String -> ContT Unit Effect (Maybe PingReply)
contPing host = ContT (\f -> do
  _ <- exec ("ping " <> host <> " -c 1") defaultExecOptions (f <<< resultToReply)
  pure unit
  )

ping :: String -> (Maybe PingReply -> Effect Unit) -> Effect Unit
ping host f = do
  runContT (contPing host) f
