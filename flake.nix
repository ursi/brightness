{
  inputs.utils.url = "/home/mason/git/flake-utils";

  outputs = { self, nixpkgs, utils }:
    utils.builders.simple-js {
      inherit nixpkgs;
      name = "brightness";
      version = "0.1.0";
      path = ./brightness.js;
      systems = [ "x86_64-linux" ];
    };
}
