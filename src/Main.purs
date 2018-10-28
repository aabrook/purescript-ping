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
import Control.Monad.Cont (ContT(..), cont, runContT)
import Mqtt

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
    run (Right r) = runContT (capturing r) (\v -> v >>= log)
    run (Left err) = log $ "Failed to load config: " <> (show err)

capturing :: Options -> ContT Unit Effect (Effect String)
capturing config = pingGoogle >>= toString >>= publishIt >>= resolve
  where
    pingGoogle = (contPing "google.com" "purescript")
    toString = pure <<< map show
    publishIt = pure <<< map (publishPing' config)
    resolve = pure <<< maybe (pure "Failed to ping") (identity)

publishPing' config result = do
  _ <- publishPing "ping" config.host config result
  pure result

publishPing :: String -> String -> Options -> String -> Effect Unit
publishPing topic host opts ping = launchAff_ $ do
  cli <- connect host opts
  _ <- publish topic ping cli
  _ <- log $ topic <> " Published"
  end cli
