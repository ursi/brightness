{
  outputs = { self, nixpkgs, utils }:
    let system = "x86_64-linux"; in
      (utils.simpleShell
        [
          "dhall"
          "nodejs"
          "purescript"
          "spago"
        ]
        nixpkgs
      )
        // {
        defaultPackage.${system} = import ./psnp.nix
          rec {
            pkgs = nixpkgs.legacyPackages.${system};
            runtimeDeps = [ pkgs.xorg.xrandr ];
          };
      };
}
