{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
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
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nix-darwin.follows = "";
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

  outputs = inputs@{ flake-parts, home-manager, nixpkgs, nixpkgs-unstable, self, agenix, ... }:
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
        formatter = pkgs.nixfmt-rfc-style;
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            opentofu
            nurl
            nixos-rebuild
            inputs.agenix.packages.${system}.default
            colmena
            nix-update
          ];
        };
        packages =
          let
            currentHostPlatform = { nixpkgs.hostPlatform = system; };
            installerImage = inputs:
              (inputs.nixpkgs.lib.nixosSystem { modules = [ ./hosts/installer/configuration.nix currentHostPlatform ]; }).config.system.build.isoImage;
          in
          {
            inherit (pkgs) opentofu;
            installer-stable = installerImage inputs;
            nixvim = inputs'.nixvim.legacyPackages.makeNixvimWithModule {
              module = import ./config/nixvim;
            };
            gitlabber-tarball = (self.nixosConfigurations.gitlabber.extendModules {
              modules = [ 
                self.nixosModules.nspawnTarball
                currentHostPlatform
              ];
            }).config.system.build.tarball;
          };
      };

      flake = {
        lib = {
          nixosSystem = nixpkgs:
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
            { config, self', system, pkgs, inputs', ... }: {
              inherit (inputs'.nixpkgs-unstable.legacyPackages) jujutsu renovate;
              wgsl-analyzer = prev.callPackage ./pkgs/wgsl-analyzer/package.nix { };
              sandwine = prev.callPackage ./pkgs/sandwine { };
              qpm-cli = inputs'.nixpkgs-unstable.legacyPackages.callPackage ./pkgs/qpm-cli/default.nix { };
              yt-dlp = prev.yt-dlp.overrideAttrs (prev: {
                patches = (prev.patches or []) ++ [ ./patches/yt-dlp-ZDF-fields.patch ];
              });
            }
          ))
        );

        nixosModules.config = import ./config/nixos;
        homeManagerModules.config = import ./config/home-manager;

        nixosConfigurations = {
          artemis = self.lib.nixosSystem nixpkgs {
            modules = [ ./hosts/artemis/configuration.nix ];
          };
          delphi = self.lib.nixosSystem nixpkgs {
            modules = [ ./hosts/delphi/configuration.nix ];
          };
          marie-desktop = self.lib.nixosSystem nixpkgs-unstable {
            modules = [ ./hosts/marie-desktop/configuration.nix ];
          };
          gitlabber = self.lib.nixosSystem nixpkgs {
            modules = [ ./hosts/gitlabber/configuration.nix ];
          };
          installer = nixpkgs.lib.nixosSystem nixpkgs {
            system = "x86_64-linux";
            modules = [
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
              ({ pkgs, ... }: {
                environment.systemPackages = [ pkgs.neovim ];
                environment.etc."dotfiles".source = self;
              })
            ];
          };
        };

        colmena = {
          meta = {
            nixpkgs = nixpkgs.legacyPackages.x86_64-linux;
            specialArgs = { inherit inputs; };
            nodeNixpkgs.delphi = nixpkgs.legacyPackages.aarch64-linux;
          };
          artemis = { name, nodes, pkgs, ... }: {
            imports = [
              ./hosts/artemis/configuration.nix
              self.nixosModules.config
            ];
            deployment.buildOnTarget = true;
            deployment.targetUser = null;
            nixpkgs.overlays = [ self.overlays.default ];
            nixpkgs.flake.source = nixpkgs;
          };
          delphi = {
            imports = [
              ./hosts/delphi/configuration.nix
              self.nixosModules.config
            ];
            deployment.buildOnTarget = true;
            deployment.targetUser = null;
            nixpkgs.overlays = [ self.overlays.default ];
            nixpkgs.flake.source = nixpkgs;
          };
          gitlabber = {
            imports = [
              ./hosts/gitlabber/configuration.nix
              self.nixosModules.config
            ];
            deployment.targetHost = "marie:gitlabber@jemand771.net";
            deployment.buildOnTarget = true;
            deployment.targetUser = null;
            nixpkgs.overlays = [ self.overlays.default ];
            nixpkgs.flake.source = nixpkgs;
          };
        };
      };
    });
}
