module Ping where

import Prelude

import Effect.Console (log)
import Effect

import Data.Array ((!!), last, take)
import Data.Maybe (Maybe(..), maybe)
import Data.String (Pattern(..), split)

import Node.ChildProcess (ExecResult(..), defaultExecOptions, exec, stdout)
import Node.Stream (onData)

newtype PingReply = PingReply
  { ttl :: String
  , time :: String
  }

instance showPing :: Show PingReply where
  show (PingReply { ttl, time }) = "Time: " <> time <> " TTL: " <> ttl

ping host = do
  exec ("ping " <> host <> " -c 1") defaultExecOptions printResult

printResult :: ExecResult -> Effect Unit
printResult { stdout } = log results
  where
    row = split (Pattern "\\n") $ show stdout
    buildReply rep = case take 4 rep of
                          [_cmp, ttl, time, ms] -> Just (PingReply {ttl, time: time <> ms})
                          _ -> Nothing
    results = do
       reply <- row !! 1
       res <- split (Pattern ": ") reply # last
       split (Pattern " ") res # buildReply
       # maybe "Failed to parse" show

