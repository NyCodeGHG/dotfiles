{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation.url = "github:nix-community/preservation";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    corsair-hs80-pipewire-thing = {
      url = "https://codeberg.org/marie/corsair-hs80-pipewire-thing/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    iplookupd = {
      url = "git+ssh://forgejo@git.marie.cologne/marie/iplookupd.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    systemd-impersonate = {
      url = "https://codeberg.org/marie/systemd-impersonate/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wii-u = {
      url = "https://codeberg.org/marie/nixos-wii-u/archive/main.tar.gz";
    };

    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-locate-man = {
      url = "https://codeberg.org/marie/nix-locate-man/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-output-monitor = {
      url = "github:maralorn/nix-output-monitor";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    principa-document-downloader = {
      url = "https://git.marie.cologne/marie/principa-document-downloader/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nixvim,
      self,
      colmena,
      systemd-impersonate,
      nixos-wii-u,
      corsair-hs80-pipewire-thing,
      nix-locate-man,
      nix-output-monitor,
      principa-document-downloader,
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
                  corsair-hs80-pipewire-thing.overlays.default
                  nix-locate-man.overlays.default
                  nix-output-monitor.overlays.default
                  principa-document-downloader.overlays.default
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
            inputs.agenix.packages.${stdenv.hostPlatform.system}.default
            (inputs.colmena.packages.${stdenv.hostPlatform.system}.colmena.override {
              inherit (lixPackageSets.latest) nix-eval-jobs;
            })
            nix-update
            grafana-alloy
          ];
        };
      });
      packages = forEachSystem nixpkgs (pkgs: self.overlays.packages pkgs pkgs);

      overlays.default = (
        final: prev:
        {
          discord = (
            prev.discord.override {
              # withOpenASAR = true;
              withVencord = true;
            }
          );

          kdePackages = prev.kdePackages.overrideScope (
            kdeFinal: kdePrev: {
              spectacle = kdePrev.spectacle.override {
                tesseractLanguages = [
                  "eng"
                  "deu"
                ];
              };
              inherit (final) kiot;
            }
          );

          nixvim = nixvim.legacyPackages.${prev.stdenv.hostPlatform.system}.makeNixvimWithModule {
            module = import ./config/nixvim;
            pkgs = final;
          };
        }
        // (self.overlays.packages final prev)
      );

      overlays.packages = (
        final: prev:
        let
          inherit (prev) lib;
          packages = lib.flip lib.pipe [
            lib.readDir
            (lib.filterAttrs (_: type: type == "directory"))
            (lib.mapAttrs (name: _: ./pkgs/${name}/package.nix))
            (lib.filterAttrs (_: path: lib.pathExists path))
            (lib.mapAttrs (_: path: prev.callPackage path { }))
          ] ./pkgs;
        in
        packages
        // {
          kiot = prev.kdePackages.callPackage ./pkgs/kiot { };
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
          inherit (inputs.nixpkgs) lib;
          patchInputs = import ./utils/patch-inputs.nix;
          importNixpkgs =
            {
              system ? "x86_64-linux",
            }:
            import nixpkgs {
              inherit system;
              overlays = [
                self.overlays.default
                systemd-impersonate.overlays.default
                corsair-hs80-pipewire-thing.overlays.default
                nix-locate-man.overlays.default
                nix-output-monitor.overlays.default
                principa-document-downloader.overlays.default
              ];
            };
          patchedInputs = patchInputs {
            inherit inputs;
            hostSystem = "x86_64-linux";
            patches =
              { npr, ... }:
              {
                nixpkgs = (lib.mapAttrsToList npr) (lib.importJSON ./patches/nixpkgs.json) ++ [
                ];
              };
          };
          inherit (patchedInputs)
            nixpkgs
            ;
        in
        colmena.lib.makeHive {
          meta = {
            nixpkgs = importNixpkgs { };
            specialArgs = {
              inputs = patchedInputs;
            };
            nodeNixpkgs = {
              delphi = importNixpkgs { system = "aarch64-linux"; };
            };
          };
          artemis = {
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
            # nix.registry.nixpkgs.flake = nixpkgs;
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
            deployment.targetHost = "marie-nas";
            deployment.buildOnTarget = false;
            deployment.targetUser = null;
            nix.registry.nixpkgs.flake = nixpkgs;
          };
          lab-client = {
            imports = [
              ./hosts/lab-client/configuration.nix
              self.nixosModules.config
            ];
            deployment.targetHost = "lab-client";
            deployment.buildOnTarget = false;
            deployment.targetUser = null;
            nix.registry.nixpkgs.flake = nixpkgs;
          };
          lab-router-a = {
            imports = [
              ./hosts/lab-router-a/configuration.nix
              self.nixosModules.config
            ];
            deployment.targetHost = "lab-router-a";
            deployment.buildOnTarget = false;
            deployment.targetUser = null;
            deployment.tags = [ "lab-router" ];
            nix.registry.nixpkgs.flake = nixpkgs;
          };
          lab-router-b = {
            imports = [
              ./hosts/lab-router-b/configuration.nix
              self.nixosModules.config
            ];
            deployment.targetHost = "lab-router-b";
            deployment.buildOnTarget = false;
            deployment.targetUser = null;
            deployment.tags = [ "lab-router" ];
            nix.registry.nixpkgs.flake = nixpkgs;
          };
          marie-desktop = {
            imports = [
              ./hosts/marie-desktop/configuration.nix
              self.nixosModules.config
            ];
            deployment.allowLocalDeployment = true;
            deployment.targetHost = null;
            nix.registry.nixpkgs.flake = nixpkgs;
          };
          wii-u = {
            imports = [
              ./hosts/wii-u/configuration.nix
              self.nixosModules.config
              nixos-wii-u.nixosModules.default
            ];
            deployment.targetHost = "192.168.1.62";
            deployment.buildOnTarget = false;
            deployment.targetUser = null;
            nix.registry.nixpkgs.flake = nixos-wii-u.inputs.nixpkgs;
            nixpkgs.buildPlatform = "x86_64-linux";
          };
          steamdeck = {
            imports = [
              ./hosts/steamdeck/configuration.nix
              self.nixosModules.config
            ];
            deployment.targetHost = "steamdeck";
            deployment.buildOnTarget = false;
            deployment.targetUser = null;
            nix.registry.nixpkgs.flake = nixpkgs;
            nixpkgs.buildPlatform = "x86_64-linux";
          };
        };
    };
}
