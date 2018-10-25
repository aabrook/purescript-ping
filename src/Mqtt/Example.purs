module Example where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Control.Monad.Error.Class (catchError)

import Effect.Aff (launchAff, launchAff_, makeAff)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), maybe)

import Mqtt

eg opts = launchAff_ $ do
    cli <- connect host options
    _ <- publish "test" "Why hello there" cli
    end cli
  where
    host = opts.host
    options = {
      username: opts.username
      , password: opts.password
      , port: opts.port
      , clientId: opts.clientId
      }
