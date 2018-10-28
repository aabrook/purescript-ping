module MainSpeedtest where

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

import Control.Monad.Cont (ContT(..), runContT)
import Mqtt
import Speedtest

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
    runSpeedtest config
  where
    runSpeedtest (Right r) = runContT contSpeedtest (publishSpeedtest "speedtest" r.host r <<< show)
    runSpeedtest (Left err) = log $ show err

publishSpeedtest topic host opts ping = launchAff_ $ do
  cli <- connect host opts
  _ <- publish topic ping cli
  _ <- log $ topic <> " Published"
  end cli

