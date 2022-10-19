{ inputs =
    { nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      purs-nix.url = "github:ursi/purs-nix";
      utils.url = "github:ursi/flake-utils/2";
    };

  outputs = { utils, ... }@inputs:
    utils.default-systems
      ({ make-shell, pkgs, purs-nix, ... }:
         let
           inherit (purs-nix) purs ps-pkgs ps-pkgs-ns;
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

                  srcs = [ ./src ];
                }
             )
             modules
             command;
         in
         { packages.default =
             (modules.Main.app { name = "brightness"; })
             .overrideAttrs (old: { buildInputs = [ pkgs.xorg.xrandr ] ++ old.buildInputs; });

           devShells.default =
             make-shell
               { packages =
                   with pkgs;
                   [ nodejs
                     purs-nix.purescript
                     purs-nix.purescript-language-server
                     (command {})
                   ];
               };
         }
      )
      inputs;
}
