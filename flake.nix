{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";

    nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";

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

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    preservation.url = "github:nix-community/preservation";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    corsair-hs80-pipewire-thing = {
      url = "https://codeberg.org/marie/corsair-hs80-pipewire-thing/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    trackerlist = {
      url = "github:ngosang/trackerslist";
      flake = false;
    };

    iplookupd = {
      url = "git+ssh://forgejo@git.marie.cologne/marie/iplookupd.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.2-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      agenix,
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-patcher,
      nixvim,
      self,
      lix-module,
      ...
    }:
    let
      forEachSystem =
        nixpkgs: f:
        nixpkgs.lib.genAttrs
          [
            "x86_64-linux"
            "aarch64-linux"
          ]
          (
            system:
            f (
              import nixpkgs {
                inherit system;
                overlays = [ self.overlays.default ];
              }
            )
          );
    in
    {
      formatter = forEachSystem nixpkgs (pkgs: pkgs.nixfmt-rfc-style);
      devShells = forEachSystem nixpkgs (pkgs: {
        default = pkgs.mkShellNoCC {
          nativeBuildInputs = with pkgs; [
            opentofu
            nurl
            nixos-rebuild
            inputs.agenix.packages.${system}.default
            colmena
            nix-update
            ansible
            ansible-lint
          ];
        };
        ansible = pkgs.mkShellNoCC {
          nativeBuildInputs = with pkgs; [
            ansible
            ansible-lint
          ];
        };
      });
      packages =
        let
          stable = forEachSystem nixpkgs (pkgs: self.overlays.packages pkgs pkgs);
          unstable = forEachSystem nixpkgs-unstable (
            pkgs:
            nixpkgs.lib.mapAttrs' (n: v: nixpkgs.lib.nameValuePair "${n}-unstable" v) (
              self.overlays.packages pkgs pkgs
            )
          );
        in
        nixpkgs.lib.recursiveUpdate stable unstable;

      lib = {
        nixosSystem =
          nixpkgs:
          {
            modules ? [ ],
            patches ? _: [ ],
          }:
          nixpkgs-patcher.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
            };
            modules = [
              { nixpkgs.overlays = [ self.overlays.default ]; }
              self.nixosModules.config
              lix-module.nixosModules.default
            ] ++ modules;

            nixpkgsPatcher = {
              inherit nixpkgs inputs patches;
            };
          };
      };

      overlays.default = (
        final: prev:
        {
          discord = (
            prev.discord.override {
              withOpenASAR = true;
              withVencord = true;
            }
          );
        }
        // (self.overlays.packages final prev)
      );

      overlays.packages = (
        final: prev:
        let
          inherit (prev) lib;
          packages = lib.mapAttrs (name: _: prev.callPackage ./pkgs/${name}/package.nix { }) (
            lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./pkgs)
          );
        in
        packages
        // {
          nixvim = nixvim.legacyPackages.${prev.stdenv.hostPlatform.system}.makeNixvimWithModule {
            module = import ./config/nixvim;
          };
        }
      );

      nixosModules = {
        config = import ./config/nixos;
        authentik = ./modules/nixos/applications/authentik.nix;
        nspawnTarball = ./modules/nixos/nspawn-tarball.nix;
        cachixUpload = ./modules/nixos/cachix-upload.nix;
      };
      homeManagerModules.config = import ./config/home-manager;

      nixosConfigurations = {
        artemis = self.lib.nixosSystem nixpkgs { modules = [ ./hosts/artemis/configuration.nix ]; };
        delphi = self.lib.nixosSystem nixpkgs { modules = [ ./hosts/delphi/configuration.nix ]; };
        marie-desktop = self.lib.nixosSystem nixpkgs-unstable {
          modules = [
            ./hosts/marie-desktop/configuration.nix
          ];
          patches =
            pkgs:
            let
              npr =
                pr: hash:
                (pkgs.fetchpatch2 {
                  url = "https://github.com/NixOS/nixpkgs/pull/${toString pr}.patch";
                  inherit hash;
                });
            in
            [
              # nexusmods-app: 0.12.3 -> 0.13.4
              (npr 421761 "sha256-AOF7lxbgnyuRIxL5APU+oUGT+dOQZNjjlTyAJVIrtio=")
            ];
        };
        gitlabber = self.lib.nixosSystem nixpkgs { modules = [ ./hosts/gitlabber/configuration.nix ]; };
        installer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            (
              { pkgs, ... }:
              {
                environment.systemPackages = [ pkgs.neovim ];
                environment.etc."dotfiles".source = self;
              }
            )
          ];
        };
        marie-nas = self.lib.nixosSystem nixpkgs-unstable {
          modules = [ ./hosts/marie-nas/configuration.nix ];
        };
        traewelldroid-prod = self.lib.nixosSystem nixpkgs {
          modules = [ ./hosts/traewelldroid-prod/configuration.nix ];
        };
      };

      colmena = {
        meta = {
          nixpkgs = nixpkgs.legacyPackages.x86_64-linux;
          specialArgs = {
            inherit inputs;
          };
          nodeNixpkgs.delphi = nixpkgs.legacyPackages.aarch64-linux;
          nodeNixpkgs.marie-nas = nixpkgs-unstable.legacyPackages.x86_64-linux;
        };
        artemis =
          {
            name,
            nodes,
            pkgs,
            ...
          }:
          {
            imports = [
              ./hosts/artemis/configuration.nix
              self.nixosModules.config
            ];
            deployment.buildOnTarget = true;
            deployment.targetUser = null;
            nixpkgs.overlays = [
              self.overlays.default
              lix-module.overlays.default
            ];
            nixpkgs.flake.source = nixpkgs;
          };
        delphi = {
          imports = [
            ./hosts/delphi/configuration.nix
            self.nixosModules.config
          ];
          deployment.buildOnTarget = true;
          deployment.targetUser = null;
          nixpkgs.overlays = [
            self.overlays.default
            lix-module.overlays.default
          ];
          nixpkgs.flake.source = nixpkgs;
        };
        gitlabber = {
          imports = [
            ./hosts/gitlabber/configuration.nix
            self.nixosModules.config
          ];
          deployment.targetHost = "root@gitlabber.weasel-gentoo.ts.net";
          deployment.buildOnTarget = true;
          deployment.targetUser = null;
          nixpkgs.overlays = [
            self.overlays.default
            lix-module.overlays.default
          ];
          nixpkgs.flake.source = nixpkgs;
        };
        marie-nas = {
          imports = [
            ./hosts/marie-nas/configuration.nix
            self.nixosModules.config
          ];
          deployment.targetHost = "192.168.1.21";
          deployment.buildOnTarget = false;
          deployment.targetUser = null;
          nixpkgs.overlays = [
            self.overlays.default
            lix-module.overlays.default
          ];
          nixpkgs.flake.source = nixpkgs-unstable;
        };
        traewelldroid-prod = {
          imports = [
            ./hosts/traewelldroid-prod/configuration.nix
            self.nixosModules.config
          ];
          deployment.targetHost = "traewelldroid-prod.marie.cologne";
          deployment.buildOnTarget = false;
          deployment.targetUser = null;
          nixpkgs.overlays = [
            self.overlays.default
            lix-module.overlays.default
          ];
          nixpkgs.flake.source = nixpkgs-unstable;
        };
      };
    };
}
