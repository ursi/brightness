{
  inputs.psnp.url = "github:ursi/psnp";

  outputs = { self, nixpkgs, utils, psnp }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
      {
        defaultPackage.${system} =
            (import ./psnp.nix { inherit pkgs; })
              .overrideAttrs (old: { buildInputs = [ pkgs.xorg.xrandr ] ++ old.buildInputs; });

        devShell.${system} = with pkgs;
          mkShell {
            buildInputs = [
              dhall
              nodejs
              psnp.defaultPackage.${system}
              purescript
              spago
            ];
          };
      };
}
