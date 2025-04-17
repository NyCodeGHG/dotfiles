{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
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
      inputs.nix-darwin.follows = "";
    };

    preservation.url = "github:nix-community/preservation/555e6ad35ac8f4f2879e09e41b0e4f397a0b74a0";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    cloudflare-exporter = {
      url = "https://codeberg.org/marie/cloudflare-prometheus-exporter/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
  };

  nixConfig = {
    extra-substituters = [
      "https://uwumarie.cachix.org"
    ];
    extra-trusted-public-keys = [
      "uwumarie.cachix.org-1:H6nX8e82pu2GQ8CGU3j1qHTG7QMYzZ15oSBh26XhtVo="
    ];
  };

  outputs =
    inputs@{
      agenix,
      nixpkgs,
      nixpkgs-unstable,
      nixvim,
      self,
      ...
    }:
    let
      forEachSystem =
        nixpkgs: f:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
        ] (system: f (import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        }));
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
          nativeBuildInputs = with pkgs; [ ansible ansible-lint ];
        };
      });
      packages = let
        stable = forEachSystem nixpkgs (pkgs: self.overlays.packages pkgs pkgs);
        unstable = forEachSystem nixpkgs-unstable (pkgs: nixpkgs.lib.mapAttrs' (n: v: nixpkgs.lib.nameValuePair "${n}-unstable" v) (self.overlays.packages pkgs pkgs));
      in (with nixpkgs.lib; recursiveUpdate (recursiveUpdate stable unstable) {
        x86_64-linux.installer-nas-iso = self.nixosConfigurations.installer-nas.config.system.build.isoImage;
      });

      lib = {
        nixosSystem =
          nixpkgs:
          nixpkgs.lib.makeOverridable (
            {
              modules ? [ ],
              baseModules ? [ ],
            }:
            nixpkgs.lib.nixosSystem {
              specialArgs = {
                inherit inputs;
              };
              modules =
                baseModules
                ++ [
                  { nixpkgs.overlays = [ self.overlays.default ]; }
                  self.nixosModules.config
                ]
                ++ modules;
            }
          );
      };

      overlays.default = self.overlays.packages;

      overlays.packages = (final: prev: {
        sandwine = prev.callPackage ./pkgs/sandwine { };
        plasma-aero-theme = prev.callPackage ./pkgs/plasma-aero-theme/package.nix { };
        btop = prev.btop.overrideAttrs (prev: {
          patches = (prev.patches or [ ]) ++ [ ./patches/btop_Fix-typo-Mhz-MHz.patch ];
        });
        nixvim = nixvim.legacyPackages.${prev.stdenv.hostPlatform.system}.makeNixvimWithModule { module = import ./config/nixvim; };
        libray= prev.callPackage ./pkgs/libray/package.nix { };
        jellyfin-plugin-sso = prev.callPackage ./pkgs/jellyfin-plugin-sso/package.nix { };
        bitmagnet = prev.callPackage ./pkgs/bitmagnet/package.nix { };
        jellyseerr = prev.callPackage ./pkgs/jellyseerr/package.nix { };
        forgejo = prev.callPackage ./pkgs/forgejo/package.nix { };
        go_1_24 = prev.callPackage ./pkgs/go_1_24/package.nix { };
        buildGo124Module = prev.buildGoModule.override {
          go = final.go_1_24;
        };
      });

      nixosModules = {
        config = import ./config/nixos;
        authentik = ./modules/nixos/applications/authentik.nix;
        coder = ./modules/nixos/applications/coder.nix;
        pgrok = ./modules/nixos/applications/pgrok.nix;
        nspawnTarball = ./modules/nixos/nspawn-tarball.nix;
        cachixUpload = ./modules/nixos/cachix-upload.nix;
      };
      homeManagerModules.config = import ./config/home-manager;

      nixosConfigurations = {
        artemis = self.lib.nixosSystem nixpkgs { modules = [ ./hosts/artemis/configuration.nix ]; };
        delphi = self.lib.nixosSystem nixpkgs { modules = [ ./hosts/delphi/configuration.nix ]; };
        marie-desktop = self.lib.nixosSystem nixpkgs-unstable {
          modules = [ ./hosts/marie-desktop/configuration.nix ];
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
        marie-nas = self.lib.nixosSystem nixpkgs {
          modules = [ ./hosts/marie-nas/configuration.nix ];
        };
        installer-nas = self.lib.nixosSystem nixpkgs {
          modules = [
            ./hosts/marie-nas/configuration.nix
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            {
              environment.etc."dotfiles".source = self;
              security.sudo-rs.enable = false;
              uwumarie.state.enable = false;
              boot.initrd.systemd.enable = nixpkgs.lib.mkForce false;
              boot.initrd.services.resolved.enable = nixpkgs.lib.mkForce false;
            }
          ];
        };
      };

      colmena = {
        meta = {
          nixpkgs = nixpkgs.legacyPackages.x86_64-linux;
          specialArgs = {
            inherit inputs;
          };
          nodeNixpkgs.delphi = nixpkgs.legacyPackages.aarch64-linux;
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
          deployment.targetHost = "root@gitlabber.weasel-gentoo.ts.net";
          deployment.buildOnTarget = true;
          deployment.targetUser = null;
          nixpkgs.overlays = [ self.overlays.default ];
          nixpkgs.flake.source = nixpkgs;
        };
        marie-nas = {
          imports = [
            ./hosts/marie-nas/configuration.nix
            self.nixosModules.config
          ];
          deployment.targetHost = "marie-nas";
          deployment.buildOnTarget = false;
          deployment.targetUser = null;
          nixpkgs.overlays = [ self.overlays.default ];
          nixpkgs.flake.source = nixpkgs;
        };
      };
    };
}
