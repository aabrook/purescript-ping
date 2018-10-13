module Main where

import Prelude

import Effect (Effect)
import Effect.Class.Console (log)

import Affjax as AX
import Affjax.RequestBody (string)
import Affjax.ResponseFormat (ignore)
import Effect.Aff (launchAff, launchAff_)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), maybe)

import Ping (PingReply(..), contPing, ping, resultToReply)
import Control.Monad.Cont (ContT(..), runContT)

forward :: Maybe PingReply -> Effect Unit
forward (Just reply) = do
  _ <- postMessage $ show reply
  pure unit
forward Nothing = log "Failed to determine ping"

main :: Effect Unit
main = do
  _ <- ping "google.com" forward
  log "Hello world"

postMessage msg = launchAff $ do
  res <- AX.post ignore "http://requestbin.fullcontact.com/12ks0jl1" (string msg)
  case res.body of
       Left err -> log $ AX.printResponseFormatError err
       Right resp -> log $ show res.status

contPost :: String -> ContT Unit Effect String
contPost msg = ContT (\f -> launchAff_ $ do
  res <- AX.post ignore "http://requestbin.fullcontact.com/12ks0jl1" (string msg)
  case res.body of
       Left err -> pure $ f $ AX.printResponseFormatError err
       Right resp -> pure $ f $ show res.status
  )

doTheThing :: String -> ContT Unit Effect String
doTheThing h = do
  r <- contPing h
  m <- pure $ maybe "Failed" show r
  contPost m
