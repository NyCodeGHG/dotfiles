{
  description = "System configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , hyprland
    , agenix
    , flake-utils
    , vscode-server
    , deploy-rs
    , ...
    } @ inputs:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      nixosConfigurations = {
        catcafe = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            agenix.nixosModules.default
            hyprland.nixosModules.default
            vscode-server.nixosModule
            home-manager.nixosModules.home-manager
            ./marie.nix
            ./hosts/common.nix
            ./hosts/catcafe
            {
              programs.hyprland.enable = true;
              services.vscode-server.enable = true;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
          specialArgs = {
            inherit inputs;
            host = {
              sshKey = "github_laptop.ed25519";
            };
            agenix = agenix.packages.x86_64-linux.default;
          };
        };
        artemis = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            agenix.nixosModules.default
            vscode-server.nixosModules.default
            ./hosts/common.nix
            ./hosts/artemis
          ];
          specialArgs = {
            inherit inputs;
            agenix = agenix.packages.x86_64-linux.default;
          };
        };
      };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixpkgs-fmt
          terraform
          google-cloud-sdk
          pkgs.deploy-rs
        ];
      };
      deploy = {
        nodes.artemis = {
          hostname = "uwu.nycode.dev";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.artemis;
          };
        };
        remoteBuild = true;
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
