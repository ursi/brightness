module Main where

import MasonPrelude
import Data.Array.NonEmpty as NEA
import Data.Number as Number
import Data.String as String
import Data.String.Regex as RE
import Data.String.Regex.Flags (noFlags)
import Effect.Exception (Error)
import Effect.Exception as Ex
import Node.Path as Path
import Node.Process as Process
import Task (Task, throwError)
import Task as Task
import Task.File as File
import Task.ChildProcess as CP
import Stdin (Keypress)
import Stdin as Stdin

main :: Effect Unit
main =
  Task.capture
    ( case _ of
        Left e -> logShow e
        Right _ -> pure unit
    ) do
    configPath <-
      liftEffect $ getHomedir
        <#> \homedir -> Path.concat [ homedir, ".brightness" ]
    current <-
      File.read configPath
        <#> Number.fromString
        .> fromMaybe 1.0
    logShow current
    monitor <- getMonitor
    keypressLoop $ keypressHandler monitor configPath $ defaultBrightness { current = current }

foreign import getHomedir :: Effect String

newtype Handler x
  = Handler (Keypress -> Task x (Handler x))

type Brightness
  = { upper :: Number
    , current :: Number
    , lower :: Number
    }

defaultBrightness :: Brightness
defaultBrightness =
  { upper: 1.0
  , current: 1.0
  , lower: 0.0
  }

keypressHandler :: String -> String -> Brightness -> Handler Error
keypressHandler monitor configPath brightness =
  Handler \{ name, ctrl } ->
    if name == "c" && ctrl then
      liftEffect $ Process.exit 0
    else
      let
        newBrightness =
          if name == "r" then
            defaultBrightness
          else if name == "up" then
            brightness
              { current = (brightness.current + brightness.upper) / 2.0
              , lower = brightness.current
              }
          else if name == "down" then
            brightness
              { current = (brightness.current + brightness.lower) / 2.0
              , upper = brightness.current
              }
          else
            brightness
      in
        do
          setBrightness monitor configPath newBrightness.current
          pure $ keypressHandler monitor configPath newBrightness

setBrightness :: String -> String -> Number -> Task Error Unit
setBrightness monitor configPath b = do
  _ <- CP.exec ("xrandr --output " <> monitor <> " --brightness " <> show b) CP.defaultExecOptions
  File.write configPath $ show b
  logShow b

keypressLoop :: ∀ x a. Handler x -> Task x a
keypressLoop (Handler handler) =
  Stdin.getKeypress
    >>= handler
    >>= keypressLoop

getMonitor :: Task Error String
getMonitor = do
  let
    error = throwError $ Ex.error "uh oh"
  rawText <- String.trim <$> CP.exec ("xrandr --listactivemonitors") CP.defaultExecOptions
  case RE.regex """[^ ]+$""" noFlags of
    Right re -> maybe error pure $ RE.match re rawText >>= NEA.head
    Left _ -> error
