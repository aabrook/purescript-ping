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

eg = launchAff_ $ do
  cli <- connect host opts
  _ <- publish "test" "Why hello there" cli
  end cli

