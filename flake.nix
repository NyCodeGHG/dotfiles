{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

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

  outputs =
    inputs@{
      agenix,
      home-manager,
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
        ] (system: f nixpkgs.legacyPackages.${system});
      packages = pkgs: {
      };
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
          ];
        };
      });
      packages = forEachSystem nixpkgs (
        pkgs:
        let
          inherit (pkgs.stdenv.hostPlatform) system;
          currentHostPlatform = {
            nixpkgs.hostPlatform = system;
          };
          installerImage =
            (nixpkgs.lib.nixosSystem {
              modules = [
                ./hosts/installer/configuration.nix
                currentHostPlatform
              ];
            }).config.system.build.isoImage;
        in
        {
          inherit (pkgs) opentofu;
          installer-stable = installerImage inputs;
          nixvim = nixvim.legacyPackages.${system}.makeNixvimWithModule { module = import ./config/nixvim; };
          wgsl-analyzer = pkgs.callPackage ./pkgs/wgsl-analyzer/package.nix { };
          sandwine = pkgs.callPackage ./pkgs/sandwine { };
          qpm-cli = nixpkgs-unstable.legacyPackages.${system}.callPackage ./pkgs/qpm-cli/default.nix { };
          alvr = pkgs.callPackage ./pkgs/alvr/package.nix { };
          yt-dlp = pkgs.yt-dlp.overrideAttrs (prev: {
            patches = (prev.patches or [ ]) ++ [ ./patches/yt-dlp-ZDF-fields.patch ];
          });
        }
      );

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

        homeManagerConfiguration = nixpkgs.lib.makeOverridable (
          {
            modules ? [ ],
            pkgs,
          }:
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              inherit inputs;
            };
            modules = [
              { nixpkgs.overlays = [ self.overlays.default ]; }
              self.homeManagerModules.config
            ] ++ modules;
          }
        );
      };

      overlays.default = (
        final: prev:
        let
          inherit (final.stdenv.hostPlatform) system;
        in
        {
          inherit (nixpkgs-unstable.legacyPackages.${system}) jujutsu;
          wgsl-analyzer = prev.callPackage ./pkgs/wgsl-analyzer/package.nix { };
          sandwine = prev.callPackage ./pkgs/sandwine { };
          qpm-cli = nixpkgs-unstable.legacyPackages.${system}.callPackage ./pkgs/qpm-cli/default.nix { };
          alvr = prev.callPackage ./pkgs/alvr/package.nix { };
          yt-dlp = prev.yt-dlp.overrideAttrs (prev: {
            patches = (prev.patches or [ ]) ++ [ ./patches/yt-dlp-ZDF-fields.patch ];
          });
        }
      );

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
        installer = nixpkgs.lib.nixosSystem nixpkgs {
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
          deployment.targetHost = "marie:gitlabber@jemand771.net";
          deployment.buildOnTarget = true;
          deployment.targetUser = null;
          nixpkgs.overlays = [ self.overlays.default ];
          nixpkgs.flake.source = nixpkgs;
        };
      };
    };
}
