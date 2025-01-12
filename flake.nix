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

    preservation.url = "github:WilliButz/preservation";

    nixos-hardware.url = "github:NixOS/nixos-hardware";
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
        ] (system: f nixpkgs.legacyPackages.${system});
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
      packages = let
        stable = forEachSystem nixpkgs (pkgs: self.overlays.packages pkgs pkgs);
        unstable = forEachSystem nixpkgs-unstable (pkgs: nixpkgs.lib.mapAttrs' (n: v: nixpkgs.lib.nameValuePair "${n}-unstable" v) (self.overlays.packages pkgs pkgs));
      in nixpkgs.lib.recursiveUpdate stable unstable;

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

      overlays.default = (
        final: prev:
        let
          inherit (final.stdenv.hostPlatform) system;
        in
        {
          inherit (nixpkgs-unstable.legacyPackages.${system}) jujutsu;
        } // self.overlays.packages final prev
      );

      overlays.packages = (final: prev: {
        wgsl-analyzer = prev.callPackage ./pkgs/wgsl-analyzer/package.nix { };
        sandwine = prev.callPackage ./pkgs/sandwine { };
        qpm-cli = prev.callPackage ./pkgs/qpm-cli/default.nix { };
        alvr = prev.callPackage ./pkgs/alvr/package.nix { };
        wivrn = prev.qt6Packages.callPackage ./pkgs/wivrn/package.nix { };
        yt-dlp = prev.yt-dlp.overrideAttrs (prev: {
          patches = (prev.patches or [ ]) ++ [ ./patches/yt-dlp-ZDF-fields.patch ];
        });
        plasma-aero-theme = prev.callPackage ./pkgs/plasma-aero-theme/package.nix { };
        btop = prev.btop.overrideAttrs (prev: {
          patches = (prev.patches or [ ]) ++ [ ./patches/btop_Fix-typo-Mhz-MHz.patch ];
        });
        nixvim = nixvim.legacyPackages.${prev.stdenv.hostPlatform.system}.makeNixvimWithModule { module = import ./config/nixvim; };
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
