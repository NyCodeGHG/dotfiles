{
  description = "System configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-scanservjs.url = "github:NyCodeGHG/nixpkgs/pkg/scanservjs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ip-playground = {
      url = "git+ssh://forgejo@git.marie.cologne/marie/ip-playground.git";
    };
    awesome-prometheus-rules = {
      url = "github:NyCodeGHG/awesome-prometheus-rules.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    steam-fetcher = {
      url = "github:nix-community/steam-fetcher";
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
        ./hosts/flake-module.nix
        ./pkgs/flake-module.nix
      ];
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.steam-fetcher.overlays.default
          ];
        };
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nixpkgs-fmt
            terraform
            google-cloud-sdk
            nurl
          ] ++ [ inputs.agenix.packages.${pkgs.system}.default inputs.deploy-rs.packages.${pkgs.system}.default ];
        };
      };
      flake =
        let
          pkgs = import nixpkgs {
            system = "x86_64-linux";
          };
        in
        {
          homeConfigurations = {
            marie = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [
                ./home
              ];
              extraSpecialArgs = {
                inherit inputs self;
                graphical = false;
              };
            };
            wsl = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [
                ./home/wsl.nix
              ];
              extraSpecialArgs = {
                inherit inputs self;
              };
            };
          };
          overlays.default = (final: prev: withSystem prev.stdenv.hostPlatform.system (
            { config, ... }: {
              inherit (inputs.nixpkgs-scanservjs.legacyPackages.${prev.stdenv.hostPlatform.system}) scanservjs;
            }
          ));
          # deploy-rs configuration
          deploy = {
            sshOpts = [ "-t" ];
            nodes = {
              artemis = {
                hostname = "uwu.nycode.dev";
                profiles.system = {
                  user = "root";
                  path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.artemis;
                };
              };
              delphi = {
                hostname = "delphi";
                profiles.system = {
                  user = "root";
                  path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.delphi;
                };
              };
              insane = {
                hostname = "insane";
                profiles.system = {
                  user = "root";
                  path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.insane;
                };
              };
            };
            # remoteBuild = true;
          };
        };
    });
}
