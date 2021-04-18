{ inputs =
    { nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      purs-nix.url = "github:ursi/purs-nix";
      utils.url = "github:ursi/flake-utils";
    };

  outputs = { nixpkgs, utils, purs-nix, ... }:
    utils.defaultSystems
      ({ make-shell, pkgs, system }:
         let
           inherit (purs-nix { inherit system; }) purs ps-pkgs ps-pkgs-ns;
           inherit
             (purs
                { dependencies =
                    with ps-pkgs-ns;
                    with ps-pkgs;
                    [ node-process
                      numbers
                      task
                      ursi.prelude
                      ursi.task-file
                      ursi.task-node-child-process
                    ];

                  src = ./src;
                }
             )
             modules
             shell;
         in
         { defaultPackage =
             (modules.Main.install { name = "brightness"; })
             .overrideAttrs (old: { buildInputs = [ pkgs.xorg.xrandr ] ++ old.buildInputs; });

           devShell =
             make-shell
               { packages =
                   with pkgs;
                   [ nodejs
                     purescript
                     (shell {})
                   ];
               };
         }
      )
      nixpkgs;
}
