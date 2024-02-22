{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ip-playground = {
      url = "git+ssh://forgejo@git.marie.cologne/marie/ip-playground.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    unlock-ssh-keys = {
      url = "git+https://codeberg.org/marie/unlock-ssh-keys";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://uwumarie.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "uwumarie.cachix.org-1:H6nX8e82pu2GQ8CGU3j1qHTG7QMYzZ15oSBh26XhtVo="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = inputs@{ flake-parts, home-manager, nixpkgs, self, ... }:
    flake-parts.lib.mkFlake ({ inherit inputs; }) ({ withSystem, ... }: {
      imports = [
        ./pkgs/flake-module.nix
        ./modules/nixos/flake-module.nix
      ];

      systems = [ "x86_64-linux" "aarch64-linux" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = [
            self.overlays.default
          ];
        };
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            opentofu
            nurl
            nixos-rebuild
            inputs.agenix.packages.${system}.default
            self'.packages.deploy
            colmena
          ];
          PRIVATE_KEY = "/home/marie/.ssh/default.ed25519";
        };
        packages =
          let
            currentHostPlatform = { nixpkgs.hostPlatform = system; };
            installerImage = inputs:
              (inputs.nixpkgs.lib.nixosSystem { modules = [ ./hosts/installer/configuration.nix currentHostPlatform ]; }).config.system.build.isoImage;
          in
          {
            inherit (pkgs) opentofu neovim-unwrapped;
            installer-stable = installerImage inputs;
          };
      };

      flake = {
        lib = {
          nixosSystem =
            nixpkgs.lib.makeOverridable ({ modules ? [ ], baseModules ? [ ] }:
              nixpkgs.lib.nixosSystem {
                specialArgs = {
                  inherit inputs;
                };
                modules = baseModules ++ [
                  { nixpkgs.overlays = [ self.overlays.default ]; }
                  self.nixosModules.config
                ] ++ modules;
              }
            );

          homeManagerConfiguration = nixpkgs.lib.makeOverridable ({ modules ? [ ], pkgs }:
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs = {
                inherit inputs;
              };
              modules = [
                { nixpkgs.overlays = [ self.overlays.default ]; }
                self.homeManagerModules.config
              ] ++ modules;
            });
        };

        overlays.default = (
          (final: prev: withSystem prev.stdenv.hostPlatform.system (
            { config, self', system, pkgs, ... }: {
              vimPlugins = prev.vimPlugins.extend (_: _: {
                inherit (self.packages.${system}) guard-nvim;
              });
            }
          ))
        );

        nixosModules.config = import ./config/nixos;
        homeManagerModules.config = import ./config/home-manager;

        nixosConfigurations = {
          artemis = self.lib.nixosSystem {
            modules = [ ./hosts/artemis/configuration.nix ];
          };
          delphi = self.lib.nixosSystem {
            modules = [ ./hosts/delphi/configuration.nix ];
          };
          minimal = self.lib.nixosSystem {
            modules = [ ./hosts/artemis/configuration.nix ];
          };
          marie-desktop = self.lib.nixosSystem {
            modules = [ ./hosts/marie-desktop/configuration.nix ];
          };
        };

        colmena = {
          artemis = { name, nodes, pkgs, ... }: {
            meta = { inherit nixpkgs; };
            deployment.buildOnTarget = true;
          };
        };
      };
    });
}
