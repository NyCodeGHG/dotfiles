{
  description = "System configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    flake-utils.url = "github:numtide/flake-utils";
    nixinate = {
      url = "github:matthewcroughan/nixinate";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , hyprland
    , agenix
    , flake-utils
    , nixinate
    , vscode-server
    , ...
    } @ inputs:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      createSystem = { name, modules ? [ ], useHomeManager ? false, host ? { }, }: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/${name}
          agenix.nixosModules.default
        ] ++ (pkgs.lib.optionals useHomeManager [
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ]) ++ modules;
        specialArgs = {
          inherit inputs host;
          agenix = agenix.packages.x86_64-linux.default;
        };
      };
    in
    {
      apps = nixinate.nixinate.x86_64-linux self;
      nixosConfigurations = {
        catcafe = createSystem {
          name = "catcafe";
          modules = [
            hyprland.nixosModules.default
            { programs.hyprland.enable = true; }
            ./marie.nix
            ./hosts/common.nix
            vscode-server.nixosModule
            { services.vscode-server.enable = true; }
          ];
          useHomeManager = true;
          host = {
            sshKey = "github_laptop.ed25519";
          };
        };
        artemis = createSystem {
          name = "artemis";
          modules = [
            {
              _module.args.nixinate = {
                host = "uwu.nycode.dev";
                sshUser = "marie";
                buildOn = "remote";
                subsituteOnTarget = true;
                hermetic = true;
              };
            }
          ];
        };
      };
      packages.x86_64-linux = {
        coder = (pkgs.callPackage ./packages/coder.nix { });
      };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixpkgs-fmt
          terraform
          google-cloud-sdk
        ];
      };
    };
}
