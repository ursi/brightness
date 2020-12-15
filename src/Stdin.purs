module Stdin where

import MasonPrelude
import Task (Canceler, ForeignCallback, Task)
import Task as Task

type Keypress
  = { name :: String
    , ctrl :: Boolean
    }

foreign import getKeypressImpl ::
  ∀ x.
  ForeignCallback Keypress ->
  ForeignCallback x ->
  Effect Canceler

getKeypress :: ∀ x. Task x Keypress
getKeypress = Task.fromForeign getKeypressImpl
