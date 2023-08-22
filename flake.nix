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

  outputs =
    { self
    , nixpkgs
    , home-manager
    , hyprland
    , agenix
    , flake-utils
    , vscode-server
    , deploy-rs
    , disko
    , ip-playground
    , awesome-prometheus-rules
    , steam-fetcher
    , ...
    } @ inputs:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ steam-fetcher.overlays.default ];
      };
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
            ./hosts/common.nix
            ./hosts/catcafe
            {
              programs.hyprland.enable = true;
              services.vscode-server.enable = true;
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.marie = import ./home;
                extraSpecialArgs = { inherit inputs; graphical = true; };
              };
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
            awesome-prometheus-rules.nixosModules.default
            agenix.nixosModules.default
            vscode-server.nixosModules.default
            home-manager.nixosModules.home-manager
            ./hosts/common.nix
            ./hosts/artemis
            {
              services.vscode-server.enable = true;
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.marie = import ./home;
                extraSpecialArgs = { inherit inputs; graphical = false; };
              };
            }
          ];
          specialArgs = {
            inherit inputs;
            agenix = agenix.packages.x86_64-linux.default;
          };
        };
        delphi = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            disko.nixosModules.disko
            ./hosts/delphi
            ./hosts/common.nix
          ];
          specialArgs = {
            inherit inputs;
            agenix = agenix.packages.aarch64-linux.default;
          };
        };
        insane = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/insane
            ./hosts/common.nix
          ];
          specialArgs = {
            inherit inputs;
          };
        };
      };
      homeConfigurations.marie = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home
        ];
        extraSpecialArgs = {
          inherit inputs;
          graphical = false;
        };
      };
      homeConfigurations.wsl = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home/wsl.nix
        ];
        extraSpecialArgs = {
          inherit inputs;
        };
      };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixpkgs-fmt
          terraform
          google-cloud-sdk
          nurl
        ] ++ [ agenix.packages.x86_64-linux.default deploy-rs.packages.x86_64-linux.default ];
      };
      deploy = {
        sshOpts = [ "-t" ];
        nodes = {
          artemis = {
            hostname = "uwu.nycode.dev";
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.artemis;
            };
          };
          delphi = {
            hostname = "delphi";
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.delphi;
            };
          };
        };
        remoteBuild = true;
      };

      packages.x86_64-linux.node-mixin = pkgs.callPackage ./pkgs/node-mixin { };
      packages.x86_64-linux.tf2-server-unwrapped = pkgs.callPackage ./pkgs/tf2-server { };
      packages.x86_64-linux.tf2-server = pkgs.callPackage ./pkgs/tf2-server/fhsenv.nix {
        inherit (self.packages.x86_64-linux) tf2-server-unwrapped;
      };
    };
}
