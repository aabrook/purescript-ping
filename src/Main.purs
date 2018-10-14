module Main where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)

import Affjax as AX
import Affjax.RequestBody (string)
import Affjax.ResponseFormat (ignore)
import Effect.Aff (launchAff, launchAff_, makeAff)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), maybe)

import Ping (PingReply(..), contPing, ping, resultToReply)
import Control.Monad.Cont (ContT(..), runContT)
import Mqtt

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

publishPing host opts ping = launchAff_ $ do
  cli <- connect host opts
  _ <- publish "ping" ping cli
  _ <- log "Ping Published"
  end cli

doThePing host opts pingTarget =
  let
      publishIt v = case v of
                         Just p -> publishPing host opts $ show p
                         Nothing -> pure unit
  in
    ping pingTarget publishIt

