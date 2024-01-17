{
  inputs = {
    # nixpkgs inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-db-rest.url = "github:NyCodeGHG/nixpkgs/nixos/db-rest";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
      inputs.darwin.follows = "";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    ip-playground = {
      url = "git+ssh://forgejo@git.marie.cologne/marie/ip-playground.git";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    awesome-prometheus-rules = {
      url = "github:NyCodeGHG/awesome-prometheus-rules.nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    unlock-ssh-keys = {
      url = "git+https://codeberg.org/marie/unlock-ssh-keys";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
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
  let
    stableInputs = inputs // { nixpkgs = inputs.nixpkgs-stable; home-manager = inputs.home-manager-stable; };
  in
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
          ];
          PRIVATE_KEY = "/home/marie/.ssh/default.ed25519";
        };
        packages =
        let
          currentHostPlatform = { nixpkgs.hostPlatform = system; };
          installerImage = inputs:
            (inputs.nixpkgs.lib.nixosSystem { modules = [ ./hosts/installer/configuration.nix currentHostPlatform ]; }).config.system.build.isoImage;
        in {
          inherit (pkgs) opentofu neovim-unwrapped;
          installer-stable = installerImage stableInputs;
          installer-unstable = installerImage inputs;
        };
      };

      flake = {
        lib = {
          nixosSystem = inputs:
          let
            inherit (inputs) nixpkgs;
          in nixpkgs.lib.makeOverridable ({ modules ? [ ], baseModules ? [ ] }:
            nixpkgs.lib.nixosSystem {
              specialArgs = {
                inherit inputs;
                configType = "nixos";
              };
              modules = baseModules ++ [
                { nixpkgs.overlays = [ self.overlays.default ]; }
                self.nixosModules.config
                "${inputs.nixpkgs-db-rest}/nixos/modules/services/misc/db-rest.nix"
              ] ++ modules;
            }
          );

          homeManagerConfiguration = nixpkgs.lib.makeOverridable ({ modules ? [ ], pkgs }:
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs = {
                inherit inputs;
                configType = "home-manager";
              };
              modules = [
                { nixpkgs.overlays = [ self.overlays.default ]; }
                self.homeManagerModules.config
              ] ++ modules;
            });
        };

        overlays.default = ((final: prev: withSystem prev.stdenv.hostPlatform.system (
          { config, self', system, pkgs, ... }: {
            vimPlugins = prev.vimPlugins.extend (_: _: {
              inherit (self.packages.${system}) guard-nvim;
            });
            unstable = inputs.nixpkgs.legacyPackages.${system};
            neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs (_: rec {
              version = "unstable-2024-11-01";
              src = prev.fetchFromGitHub {
                owner = "neovim";
                repo = "neovim";
                rev = "a767c046f4e6bff1412269d56a8edfe33857d954";
                hash = "sha256-i5jy4GWnNm20d5LbHQ7ja5x8Lba0EpanfAiYx2OGf3w=";
              };
            });
          }
        )));

        nixosModules = {
          config = import ./config/nixos;
          hybrid = import ./config/hybrid;
        };

        nixosConfigurations = {
          artemis = self.lib.nixosSystem stableInputs {
            modules = [ ./hosts/artemis/configuration.nix ];
          };
          delphi = self.lib.nixosSystem stableInputs {
            modules = [ ./hosts/delphi/configuration.nix ];
          };
          minimal = self.lib.nixosSystem stableInputs {
            modules = [ ./hosts/artemis/configuration.nix ];
          };
        };

        homeManagerModules = {
          config = import ./config/home-manager;
          hybrid = import ./config/hybrid;
        };

        homeConfigurations = {
          wsl = self.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            modules = [ ./hosts/wsl/home.nix ];
          };
        };
      };
    });
}
