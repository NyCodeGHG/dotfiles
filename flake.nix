{
  description = "System configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-pgrok.url = "github:NyCodeGHG/nixpkgs/update-pgrok";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
    };
    disko = {
      url = "github:nix-community/disko";
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
  };

  nixConfig = {
    extra-substituters = [
      "https://hyprland.cachix.org"
      "https://uwumarie.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "uwumarie.cachix.org-1:H6nX8e82pu2GQ8CGU3j1qHTG7QMYzZ15oSBh26XhtVo="
    ];
  };

  outputs = inputs@{ flake-parts, home-manager, nixpkgs, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./pkgs/flake-module.nix
        ./hosts/flake-module.nix
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
          system = builtins.currentSystem;
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
              inherit inputs;
              graphical = false;
            };
          };
          wsl = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./home/wsl.nix
            ];
            extraSpecialArgs = {
              inherit inputs;
            };
          };
        };
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
          };
          remoteBuild = true;
        };
      };
    };
}
