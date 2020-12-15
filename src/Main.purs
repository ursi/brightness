module Main where

import MasonPrelude
import Data.Number as Number
import Effect.Exception (Error)
import Node.Path as Path
import Node.Process as Process
import Task (Task)
import Task as Task
import Task.File as File
import Task.ChildProcess as CP
import Stdin (Keypress)
import Stdin as Stdin

main :: Effect Unit
main =
  Task.run do
    configPath <-
      liftEffect $ getHomedir
        <#> \homedir -> Path.concat [ homedir, ".brightness" ]
    current <-
      File.read configPath
        <#> Number.fromString
        .> fromMaybe 1.0
    logShow current
    keypressLoop $ keypressHandler configPath $ defaultBrightness { current = current }

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

keypressHandler :: String -> Brightness -> Handler Error
keypressHandler configPath brightness =
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
          setBrightness configPath newBrightness.current
          pure $ keypressHandler configPath newBrightness

setBrightness :: String -> Number -> Task Error Unit
setBrightness configPath b = do
  _ <- CP.exec ("xrandr --output HDMI-0 --brightness " <> show b) CP.defaultExecOptions
  File.write configPath $ show b
  logShow b

keypressLoop :: ∀ x a. Handler x -> Task x a
keypressLoop (Handler handler) =
  Stdin.getKeypress
    >>= handler
    >>= keypressLoop
