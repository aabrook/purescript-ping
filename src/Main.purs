module Main where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)

import Affjax as AX
import Affjax.RequestBody (string)
import Affjax.ResponseFormat (ignore)
import Effect.Aff (launchAff, launchAff_, runAff_, makeAff)
import Data.Either (Either(..), either)
import Data.Maybe (Maybe(..), maybe)

import Data.Config (Config, int, optional, prefix, string) as C
import Data.Config.Node (fromEnv) as C

import Ping (PingReply(..), contPing, ping, resultToReply)
import Control.Monad.Cont (ContT(..), runContT)
import Mqtt
import Example

mqttConfig :: C.Config {name :: String} Options
mqttConfig =
  {host: _, port: _, username: _, password: _, clientId: "ping-check"}
  <$> C.string {name: "host"}
  <*> C.string {name: "port"}
  <*> C.string {name: "username"}
  <*> C.string {name: "password"}

main :: Effect Unit
main = do
    config <- C.fromEnv "MQTT" mqttConfig
    run config
  where
    run (Right r) = ping "google.com" "purescript" (maybe (log "Failed to publish") (publishPing r.host r <<< show))
    run (Left err) = log $ show err

publishPing host opts ping = launchAff_ $ do
  cli <- connect host opts
  _ <- publish "ping" ping cli
  _ <- log "Ping Published"
  end cli
