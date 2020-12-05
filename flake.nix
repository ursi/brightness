{
  outputs = { self, nixpkgs }:
    let system = "x86_64-linux"; in
      {
        defaultPackage.${system} = with nixpkgs.legacyPackages.${system};
          stdenv.mkDerivation {
            pname = "brightness";
            version = "0.1.0";
            buildInputs = [ nodejs ];
            dontUnpack = true;
            js = ./brightness.js;

            installPhase = ''
              mkdir -p $out/bin
              local ex=$out/bin/brightness
              cp $js $ex
              chmod +x $ex
            '';
          };
      };
}
