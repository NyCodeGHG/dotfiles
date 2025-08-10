{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";

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

    nixpkgs-xr = {
      url = "github:nix-community/nixpkgs-xr";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    systemd-impersonate = {
      url = "https://codeberg.org/marie/systemd-impersonate/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    inputs@{
      agenix,
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-xr,
      nixvim,
      self,
      colmena,
      systemd-impersonate,
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
                overlays = [
                  self.overlays.default
                  systemd-impersonate.overlays.default
                ];
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
            (inputs.colmena.packages.${system}.colmena.override {
              inherit (lixPackageSets.latest) nix-eval-jobs;
            })
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

      overlays.default = (
        final: prev:
        {
          # discord = (
          #   prev.discord.override {
          #     withOpenASAR = true;
          #     withVencord = true;
          #   }
          # );
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

      nixosConfigurations = self.colmenaHive.nodes;

      colmenaHive =
        let
          patchInputs = import ./utils/patch-inputs.nix;
          importNixpkgs =
            {
              nixpkgs,
              system ? "x86_64-linux",
            }:
            import nixpkgs {
              inherit system;
              overlays = [
                self.overlays.default
                systemd-impersonate.overlays.default
              ];
            };
          patchedInputs = patchInputs {
            inherit inputs;
            hostSystem = "x86_64-linux";
            patches =
              { npr, ... }:
              {
                nixpkgs-unstable = [
                ];
                nixpkgs = [
                ];
              };
          };
          inherit (patchedInputs)
            nixpkgs
            nixpkgs-unstable
            ;
        in
        colmena.lib.makeHive {
          meta = {
            nixpkgs = importNixpkgs { inherit nixpkgs; };
            specialArgs = {
              inputs = patchedInputs;
            };
            nodeNixpkgs = {
              delphi = importNixpkgs {
                inherit nixpkgs;
                system = "aarch64-linux";
              };
              marie-nas = importNixpkgs { nixpkgs = nixpkgs-unstable; };
              marie-desktop = importNixpkgs {
                nixpkgs = nixpkgs-unstable;
              };
            };
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
              nix.registry.nixpkgs.flake = nixpkgs;
            };
          delphi = {
            imports = [
              ./hosts/delphi/configuration.nix
              self.nixosModules.config
            ];
            deployment.buildOnTarget = true;
            deployment.targetUser = null;
          };
          gitlabber = {
            imports = [
              ./hosts/gitlabber/configuration.nix
              self.nixosModules.config
            ];
            deployment.targetHost = "root@gitlabber.weasel-gentoo.ts.net";
            deployment.buildOnTarget = true;
            deployment.targetUser = null;
            nix.registry.nixpkgs.flake = nixpkgs;
          };
          marie-nas = {
            imports = [
              ./hosts/marie-nas/configuration.nix
              self.nixosModules.config
            ];
            deployment.targetHost = "192.168.1.21";
            deployment.buildOnTarget = false;
            deployment.targetUser = null;
            nix.registry.nixpkgs.flake = nixpkgs-unstable;
          };
          marie-desktop = {
            imports = [
              ./hosts/marie-desktop/configuration.nix
              self.nixosModules.config
              nixpkgs-xr.nixosModules.nixpkgs-xr
            ];
            deployment.allowLocalDeployment = true;
            deployment.targetHost = null;
            nix.registry.nixpkgs.flake = nixpkgs-unstable;
          };
        };
    };
}
