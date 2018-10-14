module Mqtt where

import Effect (Effect)
import Effect.Exception (Error)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)

import Prelude
import Data.Unit (Unit)
import Data.Either (Either)

-- | A JavaScript MQTT client.
foreign import data Client :: Type

type Options =
  { port     :: Int
  , clientId :: String
  , username :: String
  , password :: String
  }

foreign import _connect :: String -> Options -> EffectFnAff Client

foreign import _end :: Client -> EffectFnAff Unit

foreign import _subscribe :: String -> Client -> EffectFnAff Unit

foreign import _publish :: String -> String -> Client -> EffectFnAff Unit

foreign import _onConnect :: Client -> EffectFnAff Unit

foreign import _onMessage :: (String -> String -> Effect Unit) -> Client -> EffectFnAff Unit

foreign import _onClose :: (Unit -> EffectFnAff Unit) -> EffectFnAff Unit

connect :: String -> Options -> Aff Client
connect h opts = (fromEffectFnAff $ _connect h opts)

end :: Client -> Aff Unit
end cli = fromEffectFnAff $ _end cli

publish :: String -> String -> Client -> Aff Unit
publish topic msg cli = fromEffectFnAff $ _publish topic msg cli

onConnect :: Client -> Aff Unit
onConnect = fromEffectFnAff <<< _onConnect

subscribe :: String -> Client -> Aff Unit
subscribe topic cli = fromEffectFnAff $ _subscribe topic cli
