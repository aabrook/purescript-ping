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
  , source :: String
  , host :: String
  }

instance showPing :: Show PingReply where
  show (PingReply { ttl, time, source, host }) = "{\"time\": \"" <> time <> "\",\"ttl\": \"" <> ttl <> "\", \"source\": \"" <> source <> "\", \"destination\": \"" <> host <> "\"}"

resultToReply :: String -> String -> ExecResult -> Maybe PingReply
resultToReply host source { stdout } = do
  row <- pure $ split (Pattern "\\n") $ show stdout
  reply <- row !! 1
  res <- last $ split (Pattern ": ") reply
  response <- pure $ take 4 $ split (Pattern " ") res
  case response of
    [_cmp, ttl, time, ms] -> Just (PingReply {ttl, time: time <> ms, host: host, source: source})
    _ -> Nothing

contPing :: String -> String -> ContT Unit Effect (Maybe PingReply)
contPing host source = ContT (\f -> do
  _ <- exec ("ping " <> host <> " -c 1") defaultExecOptions (f <<< resultToReply host source)
  pure unit
  )

ping :: String -> String -> (Maybe PingReply -> Effect Unit) -> Effect Unit
ping host source f = do
  runContT (contPing host source) f
