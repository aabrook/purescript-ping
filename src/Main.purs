module Main where

import Prelude

import Effect (Effect)
import Effect.Class.Console (log)

import Ping (ping)

main :: Effect Unit
main = do
  _ <- ping "google.com"
  log "Hello world"
