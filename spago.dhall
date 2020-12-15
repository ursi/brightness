{ name = "brightness"
, dependencies =
  [ "mason-prelude"
  , "node-process"
  , "numbers"
  , "task"
  , "task-file"
  , "task-node-child-process"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
, version = "0.1.0"
}
